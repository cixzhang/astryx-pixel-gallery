// Copyright (c) Meta Platforms, Inc. and affiliates.

/**
 * @file Center.tsx
 * @input Uses React, StyleX for centering styles, Layout padding.stylex for spacing-scale padding
 * @output Exports Center component and CenterProps
 * @position Center component for one- or two-axis flex centering
 *
 * SYNC: When modified, update these files to stay in sync:
 * - /packages/core/src/Center/Center.doc.mjs
 * - /packages/core/src/Center/Center.spec.md
 * - /packages/core/src/Center/Center.test.tsx
 * - /apps/storybook/stories/Center.stories.tsx
 * - /packages/cli/assets/templates/blocks/components/Center/ (showcase blocks)
 */

import * as stylex from '@stylexjs/stylex';
import { paddingInlineStartStyles, paddingInlineEndStyles, paddingBlockStartStyles, paddingBlockEndStyles } from "../Layout/padding.stylex.js";
import { mergeProps } from "../utils/index.js";
import { themeProps } from "../utils/themeProps.js";
import { jsx as _jsx } from "react/jsx-runtime";
const styles = {
  base: {
    k1xSpc: "x78zum5",
    $$css: true
  },
  inline: {
    k1xSpc: "x3nfvp2",
    $$css: true
  },
  alignItemsCenter: {
    kGNEyG: "x6s0dn4",
    $$css: true
  },
  justifyContentCenter: {
    kjj79g: "xl56j7k",
    $$css: true
  }
};

// Dynamic styles for sizing props
const dynamicStyles = {
  sizing: (width, height, maxWidth, minHeight) => [{
    kzqmXN: width != null ? "x5lhr3w" : width,
    kZKoxP: height != null ? "x16ye13r" : height,
    ks0D6T: maxWidth != null ? "xf68679" : maxWidth,
    kAzted: minHeight != null ? "x82snj4" : minHeight,
    $$css: true
  }, {
    "--x-width": (val => typeof val === "number" ? val + "px" : val != null ? val : undefined)(width),
    "--x-height": (val => typeof val === "number" ? val + "px" : val != null ? val : undefined)(height),
    "--x-maxWidth": (val => typeof val === "number" ? val + "px" : val != null ? val : undefined)(maxWidth),
    "--x-minHeight": (val => typeof val === "number" ? val + "px" : val != null ? val : undefined)(minHeight)
  }]
};
/**
 * Center component for centering children on one or both flex axes.
 *
 * In horizontal writing, the single-axis names match physical horizontal and
 * vertical dimensions. In vertical writing, the current single-axis behavior
 * follows flex main/cross axes; `both` still centers on both axes.
 *
 * @example
 * ```
 * <Center width={300} height={200}>
 *   <Content />
 * </Center>
 * ```
 */
export function Center({
  axis = 'both',
  width,
  height,
  maxWidth,
  minHeight,
  padding,
  paddingInline,
  paddingInlineStart,
  paddingInlineEnd,
  paddingBlock,
  paddingBlockStart,
  paddingBlockEnd,
  isInline = false,
  children,
  xstyle,
  className,
  style,
  ref,
  ...props
}) {
  // Resolve padding to per-edge values. Most specific wins, per edge:
  // edge prop -> axis prop -> `padding`.
  const resolvedPaddingInlineStart = paddingInlineStart ?? paddingInline ?? padding;
  const resolvedPaddingInlineEnd = paddingInlineEnd ?? paddingInline ?? padding;
  const resolvedPaddingBlockStart = paddingBlockStart ?? paddingBlock ?? padding;
  const resolvedPaddingBlockEnd = paddingBlockEnd ?? paddingBlock ?? padding;
  const stylexProps = mergeProps(themeProps('center', {
    axis
  }), stylex.props(isInline ? styles.inline : styles.base, (axis === 'both' || axis === 'vertical') && styles.alignItemsCenter, (axis === 'both' || axis === 'horizontal') && styles.justifyContentCenter, dynamicStyles.sizing(width ?? null, height ?? null, maxWidth ?? null, minHeight ?? null), resolvedPaddingInlineStart != null && paddingInlineStartStyles[resolvedPaddingInlineStart], resolvedPaddingInlineEnd != null && paddingInlineEndStyles[resolvedPaddingInlineEnd], resolvedPaddingBlockStart != null && paddingBlockStartStyles[resolvedPaddingBlockStart], resolvedPaddingBlockEnd != null && paddingBlockEndStyles[resolvedPaddingBlockEnd], xstyle), className, style);
  return /*#__PURE__*/_jsx("div", {
    ref: ref,
    ...props,
    ...stylexProps,
    children: children
  });
}
Center.displayName = 'Center';