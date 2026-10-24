// Copyright (c) Meta Platforms, Inc. and affiliates.

import { stableClassName } from "../naming.js";
export function themeDataAttributeName(prop) {
  return `data-${prop.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase()}`;
}
function legacyClassTokenForPropValue(prop, value) {
  // CSS classes cannot start with a digit, so preserve the released prop prefix.
  return /^\d/.test(value) ? `${prop}-${value}` : value;
}

/**
 * Build the stable astryx-* class name string for a component.
 *
 * Every component renders one stable target class (`astryx-button`,
 * `astryx-card`, etc.). Visual props and runtime states use explicit data
 * attributes (`data-variant`, `data-size`, `data-selected`, etc.) as their
 * canonical selector surface. Released bare value/state classes remain on the
 * same element as deprecated compatibility aliases until their 0.7.0 removal
 * window.
 *
 * The `astryx-` prefix comes from the centralized naming module
 * (`packages/core/src/naming.ts`) so the namespace lives in one place.
 *
 * <!-- SYNC: packages/core/src/naming.ts (namespace prefix source of truth) -->
 * <!-- SYNC: packages/core/src/utils/parseStyleKey.ts -->
 *
 * @param component - Component name in lowercase (e.g. 'button', 'card')
 * @param props - Visual prop values whose released bare classes remain aliases
 * @returns Stable target and deprecated compatibility classes
 */
function buildClassName(component, props) {
  const classes = [stableClassName(component)];
  if (props) {
    for (const [prop, value] of Object.entries(props)) {
      if (value == null) {
        continue;
      }
      classes.push(legacyClassTokenForPropValue(prop, String(value)));
    }
  }
  return classes.join(' ');
}

/**
 * Reflect Astryx visual props as `data-*` attributes.
 *
 * Keys are kebab-cased (`listStyle` → `data-list-style`) and values are the
 * literal prop values, including numeric values (`level: 1` → `data-level="1"`).
 * Nullish values are omitted.
 */
export function themeDataAttributes(props) {
  const attrs = {};
  if (props) {
    for (const [prop, value] of Object.entries(props)) {
      if (value == null) {
        continue;
      }
      attrs[themeDataAttributeName(prop)] = String(value);
    }
  }
  return attrs;
}

/**
 * Build the props object components should spread onto the same element that
 * receives the stable Astryx class name.
 *
 * This emits one stable Astryx target, deprecated bare compatibility classes,
 * and canonical data-attribute reflection for visual props and runtime states.
 * For example:
 *
 * ```ts
 * themeProps('button', { variant: 'primary', size: 'sm' })
 * // → { className: 'astryx-button primary sm', data-variant: 'primary', data-size: 'sm' }
 * ```
 */
/**
 * Options for {@link themeProps}.
 */

export function themeProps(component, props, options) {
  const className = buildClassName(component, props);
  const legacy = options?.legacyNames?.map(name => stableClassName(name)) ?? [];
  return {
    className: legacy.length > 0 ? [className, ...legacy].join(' ') : className,
    ...themeDataAttributes(props)
  };
}