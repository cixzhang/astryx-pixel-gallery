// Copyright (c) Meta Platforms, Inc. and affiliates.

/** Private DOM registry used by future axis-aware Sticky consumers. */

const owners = new WeakMap();
export function registerScrollOwner(element, state) {
  owners.set(element, state);
}
export function unregisterScrollOwner(element) {
  owners.delete(element);
}
export function getRegisteredScrollOwnerState(element) {
  return owners.get(element);
}
export function findNearestScrollOwner(element, axis) {
  let candidate = element.parentElement;
  while (candidate != null) {
    if (owners.get(candidate)?.[axis].isScrollable === true) {
      return candidate;
    }
    candidate = candidate.parentElement;
  }
  return null;
}