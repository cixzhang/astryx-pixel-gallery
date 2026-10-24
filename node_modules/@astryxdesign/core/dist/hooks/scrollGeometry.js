// Copyright (c) Meta Platforms, Inc. and affiliates.

/** Shared geometry primitives for logical-axis scroll ownership. */

export const SCROLL_OVERFLOW_TOLERANCE = 1;
const INACTIVE_AXIS_STATE = {
  isScrollable: false,
  atStart: true,
  atEnd: true
};
export function getLogicalAxisMapping(writingMode, direction) {
  const mode = writingMode.toLowerCase();
  const isVertical = mode.startsWith('vertical') || mode.startsWith('sideways');
  const isRtl = direction === 'rtl';
  if (!isVertical) {
    return {
      inline: 'x',
      block: 'y',
      inlineReversed: isRtl,
      blockReversed: false
    };
  }

  // sideways-lr runs its natural inline direction from bottom to top. The
  // other vertical/sideways modes run top to bottom; `direction` reverses each.
  const inlineReversed = mode === 'sideways-lr' ? !isRtl : isRtl;
  const blockReversed = mode.endsWith('-rl');
  return {
    inline: 'y',
    block: 'x',
    inlineReversed,
    blockReversed
  };
}
export function isScrollCapableOverflow(value) {
  return value === 'auto' || value === 'scroll' || value === 'overlay';
}
function physicalMetrics(element, physicalAxis) {
  const computedStyle = getComputedStyle(element);
  if (physicalAxis === 'x') {
    return {
      clientExtent: element.clientWidth,
      contentExtent: element.scrollWidth,
      offset: element.scrollLeft,
      overflow: computedStyle.overflowX
    };
  }
  return {
    clientExtent: element.clientHeight,
    contentExtent: element.scrollHeight,
    offset: element.scrollTop,
    overflow: computedStyle.overflowY
  };
}
function isMeasurable(element, computedStyle) {
  return element.isConnected && computedStyle.display !== 'none' && element.clientWidth > 0 && element.clientHeight > 0;
}
export function measureLogicalOverflowGeometry(element, logicalAxis, mapping) {
  const computedStyle = getComputedStyle(element);
  if (!isMeasurable(element, computedStyle)) {
    return null;
  }
  const physicalAxis = mapping[logicalAxis];
  const clientExtent = physicalAxis === 'x' ? element.clientWidth : element.clientHeight;
  const contentExtent = physicalAxis === 'x' ? element.scrollWidth : element.scrollHeight;
  return contentExtent - clientExtent > SCROLL_OVERFLOW_TOLERANCE;
}
export function measureLogicalScrollAxis(element, logicalAxis, mapping) {
  const computedStyle = getComputedStyle(element);
  if (!isMeasurable(element, computedStyle)) {
    return null;
  }
  const physicalAxis = mapping[logicalAxis];
  const metrics = physicalMetrics(element, physicalAxis);
  const maxOffset = metrics.contentExtent - metrics.clientExtent;
  if (!isScrollCapableOverflow(metrics.overflow) || maxOffset <= SCROLL_OVERFLOW_TOLERANCE) {
    return INACTIVE_AXIS_STATE;
  }
  const isReversed = mapping[`${logicalAxis}Reversed`];
  const logicalOffset = Math.min(maxOffset, Math.max(0, isReversed ? Math.abs(metrics.offset) : metrics.offset));
  return {
    isScrollable: true,
    atStart: logicalOffset <= SCROLL_OVERFLOW_TOLERANCE,
    atEnd: logicalOffset >= maxOffset - SCROLL_OVERFLOW_TOLERANCE
  };
}