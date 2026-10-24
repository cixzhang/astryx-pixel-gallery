// Copyright (c) Meta Platforms, Inc. and affiliates.

'use client';

/**
 * @file useHighlightedOptionScroll.ts
 * @input Open state, the highlighted option index, its setter, and an
 *   option-id resolver for the owning listbox
 * @output Exports useHighlightedOptionScroll: keeps the highlighted option
 *   scrolled into view for keyboard navigation while hover-driven highlights
 *   never scroll
 * @position Internal hook; used by useCombobox, useMultiCombobox,
 *   BaseTypeahead, and DateTimeInput — the owners of combobox highlight state
 */
import { useCallback, useEffect, useRef } from 'react';
/**
 * Keep the highlighted option visible during keyboard navigation — but not for
 * hover highlights. Hover must highlight only: scrollIntoView moves the next
 * option under the stationary pointer, whose mouseenter re-highlights and
 * scrolls again — a runaway auto-scroll loop with no user input (#6077).
 * Keyboard paths call the raw setter directly and keep their scrolling; hover
 * paths call the returned callback.
 */
export function useHighlightedOptionScroll({
  isOpen,
  highlightedIndex,
  setHighlightedIndex,
  getOptionId,
  itemCount
}) {
  const hoverHighlightRef = useRef(false);
  const highlightFromHover = useCallback(index => {
    if (index !== highlightedIndex) {
      hoverHighlightRef.current = true;
    }
    setHighlightedIndex(index);
  }, [highlightedIndex, setHighlightedIndex]);
  useEffect(() => {
    if (hoverHighlightRef.current) {
      hoverHighlightRef.current = false;
      return;
    }
    if (!isOpen || highlightedIndex < 0) {
      return;
    }
    document.getElementById(getOptionId(highlightedIndex))?.scrollIntoView?.({
      block: 'nearest'
    });
  }, [isOpen, highlightedIndex, getOptionId, itemCount]);
  return highlightFromHover;
}