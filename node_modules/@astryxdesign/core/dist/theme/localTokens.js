// Copyright (c) Meta Platforms, Inc. and affiliates.

/**
 * @file localTokens.ts
 * @input Root and adaptation theme-local token declarations and references
 * @output Validated exact-name ownership metadata plus normalized conditional writes
 * @position Theme-local ownership boundary; final adaptation-cycle validation is
 *   performed after the reachable ordered cascade is assembled.
 */

const CSS_NAME_CHARACTER = String.raw`(?:[-_a-zA-Z0-9]|\P{ASCII}|\\(?:[0-9a-fA-F]{1,6}[ \t\r\n\f]?|[^\r\n\f]))`;
const CSS_CUSTOM_PROPERTY_NAME_PATTERN = new RegExp(`^--${CSS_NAME_CHARACTER}*$`, 'u');
const CSS_VAR_PATTERN = new RegExp(`var\\(\\s*(--${CSS_NAME_CHARACTER}*)(?=\\s*(?:,|\\)))`, 'giu');
function hasOwn(object, key) {
  return Object.prototype.hasOwnProperty.call(object, key);
}
function isValidCSSCustomPropertyName(name) {
  return !name.includes('\0') && CSS_CUSTOM_PROPERTY_NAME_PATTERN.test(name);
}
function resolveTokenValue(value, path) {
  if (typeof value === 'string') {
    return value;
  }
  if (Array.isArray(value) && value.length === 2 && typeof value[0] === 'string' && typeof value[1] === 'string') {
    return `light-dark(${value[0]}, ${value[1]})`;
  }
  throw new Error(`${path} must be a CSS string or a [light, dark] string tuple.`);
}
function collectCustomPropertyReferences(value, refs) {
  if (typeof value === 'string') {
    CSS_VAR_PATTERN.lastIndex = 0;
    for (let match = CSS_VAR_PATTERN.exec(value); match; match = CSS_VAR_PATTERN.exec(value)) {
      refs.add(match[1]);
    }
    return;
  }
  if (Array.isArray(value)) {
    for (const item of value) {
      collectCustomPropertyReferences(item, refs);
    }
    return;
  }
  if (value && typeof value === 'object') {
    for (const nested of Object.values(value)) {
      collectCustomPropertyReferences(nested, refs);
    }
  }
}
export function assertNoTokenCycles(tokenValues, context, relevantNames) {
  const dependencies = new Map();
  for (const [name, value] of Object.entries(tokenValues)) {
    const refs = new Set();
    collectCustomPropertyReferences(value, refs);
    dependencies.set(name, [...refs].filter(reference => hasOwn(tokenValues, reference)));
  }
  const findCyclePath = (start, component) => {
    const path = [start];
    const onPath = new Set(path);
    const search = name => {
      for (const dependency of dependencies.get(name) ?? []) {
        if (!component.has(dependency)) {
          continue;
        }
        if (dependency === start) {
          path.push(start);
          return true;
        }
        if (onPath.has(dependency)) {
          continue;
        }
        path.push(dependency);
        onPath.add(dependency);
        if (search(dependency)) {
          return true;
        }
        onPath.delete(dependency);
        path.pop();
      }
      return false;
    };
    search(start);
    return path;
  };
  let nextIndex = 0;
  const indexes = new Map();
  const lowlinks = new Map();
  const stack = [];
  const onStack = new Set();
  const visit = name => {
    const index = nextIndex++;
    indexes.set(name, index);
    lowlinks.set(name, index);
    stack.push(name);
    onStack.add(name);
    for (const dependency of dependencies.get(name) ?? []) {
      if (!indexes.has(dependency)) {
        visit(dependency);
        lowlinks.set(name, Math.min(lowlinks.get(name) ?? index, lowlinks.get(dependency) ?? 0));
      } else if (onStack.has(dependency)) {
        lowlinks.set(name, Math.min(lowlinks.get(name) ?? index, indexes.get(dependency) ?? 0));
      }
    }
    if (lowlinks.get(name) !== index) {
      return;
    }
    const component = [];
    let member;
    do {
      member = stack.pop() ?? name;
      onStack.delete(member);
      component.push(member);
    } while (member !== name);
    const hasCycle = component.length > 1 || (dependencies.get(component[0]) ?? []).includes(component[0]);
    if (!hasCycle || relevantNames && !component.some(componentName => relevantNames.has(componentName))) {
      return;
    }
    const start = component.find(componentName => relevantNames?.has(componentName)) ?? component[0];
    const cycle = findCyclePath(start, new Set(component)).join(' -> ');
    throw new Error(`${context ? `${context}: ` : ''}Theme token cycle detected: ${cycle}.`);
  };
  for (const name of Object.keys(tokenValues)) {
    if (!indexes.has(name)) {
      visit(name);
    }
  }
}
function assertInheritedContract(themeName, base) {
  const lineage = base.__localTokenLineage;
  if (!Array.isArray(lineage) || lineage.length === 0 || lineage[lineage.length - 1] !== base.name || lineage.some(name => typeof name !== 'string' || name.length === 0)) {
    throw new Error(`defineTheme("${themeName}"): the base theme has invalid theme-local token lineage metadata.`);
  }
  if (!base.localTokens || typeof base.localTokens !== 'object' || Array.isArray(base.localTokens) || !base.__localTokenOwners || typeof base.__localTokenOwners !== 'object' || Array.isArray(base.__localTokenOwners)) {
    throw new Error(`defineTheme("${themeName}"): the base theme has incomplete theme-local token metadata.`);
  }
  for (const [name, value] of Object.entries(base.localTokens)) {
    const owner = base.__localTokenOwners[name];
    if (typeof value !== 'string' || !owner || !lineage.includes(owner) || !isValidCSSCustomPropertyName(name)) {
      throw new Error(`defineTheme("${themeName}"): inherited local token "${name}" does not match its exact lineage metadata.`);
    }
  }
  for (const name of Object.keys(base.__localTokenOwners)) {
    if (!hasOwn(base.localTokens, name)) {
      throw new Error(`defineTheme("${themeName}"): inherited local-token owner metadata names undeclared token "${name}".`);
    }
  }
}

/**
 * Resolve and validate the opt-in theme-local token contract.
 *
 * Themes that omit `localTokens` and do not extend an enrolled base bypass this
 * function's exact owner and lineage checks so legacy token behavior stays intact.
 */
export function resolveLocalTokenContract(input, base, tokens, portableTokens) {
  const directlyEnrolled = hasOwn(input, 'localTokens');
  const inherited = base?.__localTokenLineage !== undefined;
  if (!directlyEnrolled && !inherited) {
    return undefined;
  }
  if (inherited && base) {
    assertInheritedContract(input.name, base);
  }
  const localTokens = {
    ...base?.localTokens
  };
  const owners = {
    ...base?.__localTokenOwners
  };
  const declarations = input.localTokens;
  if (directlyEnrolled && (declarations === null || declarations === undefined || typeof declarations !== 'object' || Array.isArray(declarations))) {
    throw new Error(`defineTheme("${input.name}"): localTokens must be a token map.`);
  }
  for (const [name, value] of Object.entries(declarations ?? {})) {
    const inheritedOwner = owners[name];
    if (!isValidCSSCustomPropertyName(name)) {
      throw new Error(`defineTheme("${input.name}"): local token "${name}" must be a valid CSS custom-property name.`);
    }
    if (!inheritedOwner) {
      owners[name] = input.name;
    }
    localTokens[name] = resolveTokenValue(value, `defineTheme("${input.name}").localTokens["${name}"]`);
  }
  for (const name of Object.keys(localTokens)) {
    if (!owners[name]) {
      throw new Error(`defineTheme("${input.name}"): inherited local token "${name}" has no owner metadata.`);
    }
    if (hasOwn(tokens, name) || hasOwn(portableTokens, name)) {
      throw new Error(`defineTheme("${input.name}"): token "${name}" cannot be declared in both tokens and localTokens.`);
    }
  }
  assertNoTokenCycles(localTokens, `defineTheme("${input.name}").localTokens`);
  return {
    localTokens,
    owners,
    lineage: [...(base?.__localTokenLineage ?? []), input.name]
  };
}

/**
 * Resolve theme-local values written by one adaptation rule.
 *
 * Adaptations may replace names already enrolled by the root theme lineage, but
 * they never enroll names of their own. Cycle validation waits until all
 * co-matching writes have cascaded in order.
 */
export function resolveAdaptationLocalTokens(themeName, ruleIndex, declarations, rootLocalTokens) {
  const path = `defineTheme("${themeName}").adaptations.rules[${ruleIndex}].value.localTokens`;
  if (declarations === undefined) {
    return undefined;
  }
  if (declarations === null || typeof declarations !== 'object' || Array.isArray(declarations)) {
    throw new Error(`${path} must be a token map.`);
  }
  const resolved = {};
  for (const [name, value] of Object.entries(declarations)) {
    if (!rootLocalTokens || !hasOwn(rootLocalTokens, name)) {
      throw new Error(`${path}["${name}"] cannot enroll a theme-local token. Declare it in the root theme or an exact enrolled base first.`);
    }
    resolved[name] = resolveTokenValue(value, `${path}["${name}"]`);
  }
  return Object.keys(resolved).length > 0 ? resolved : undefined;
}