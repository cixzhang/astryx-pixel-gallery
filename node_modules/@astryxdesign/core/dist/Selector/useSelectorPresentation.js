// Copyright (c) Meta Platforms, Inc. and affiliates.

'use client';

/**
 * @file useSelectorPresentation.ts
 * @input Uses the shared adaptive presentation policy and usePopover
 * @output Coordinates popover and bottom-sheet disclosure state
 * @position Internal presentation controller shared by Selector and MultiSelector
 */
import { useCallback, useRef, useState } from 'react';
import { usePopover } from "../Popover/usePopover.js";
import { useAdaptivePresentation } from "../hooks/useAdaptivePresentation.js";
import { useFocusReturnVisibility } from "../hooks/useFocusReturnVisibility.js";
export function useSelectorPresentation({
  presentation,
  onHide,
  onShow,
  popoverOptions,
  triggerRef
}) {
  const resolvedPresentation = useAdaptivePresentation(presentation);
  const activePresentationRef = useRef(resolvedPresentation);
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const isSheetOpenRef = useRef(false);
  // BottomSheet owns its exit animation and final-focus handoff. Keep it mounted
  // after the controlled open state turns false until that handoff reaches the
  // trigger, then consumers may remove the hidden surface tree.
  const [isSheetPresented, setIsSheetPresented] = useState(false);
  const onHideRef = useRef(onHide);
  const onShowRef = useRef(onShow);
  const didShowPopoverRef = useRef(false);
  const {
    isFocusRingSuppressed,
    onFocusReturnTargetFocus,
    prepareFocusReturn,
    resetFocusReturn
  } = useFocusReturnVisibility();
  onHideRef.current = onHide;
  onShowRef.current = onShow;
  const handlePopoverHide = useCallback(() => {
    prepareFocusReturn();
    onHideRef.current();
    triggerRef.current?.focus();
  }, [prepareFocusReturn, triggerRef]);
  const handlePopoverShow = useCallback(() => {
    didShowPopoverRef.current = true;
    resetFocusReturn();
    onShowRef.current();
  }, [resetFocusReturn]);
  const popover = usePopover({
    ...popoverOptions,
    onHide: handlePopoverHide,
    onShow: handlePopoverShow
  });
  const {
    hide: hidePopover,
    show: showPopover
  } = popover;
  const show = useCallback(() => {
    activePresentationRef.current = resolvedPresentation;
    if (resolvedPresentation === 'bottom-sheet') {
      resetFocusReturn();
      onShowRef.current();
      isSheetOpenRef.current = true;
      setIsSheetPresented(true);
      setIsSheetOpen(true);
      return true;
    }
    setIsSheetPresented(false);
    didShowPopoverRef.current = false;
    showPopover();
    return didShowPopoverRef.current;
  }, [resetFocusReturn, resolvedPresentation, showPopover]);
  const hide = useCallback(() => {
    if (isSheetOpenRef.current) {
      prepareFocusReturn();
      isSheetOpenRef.current = false;
      setIsSheetOpen(false);
      onHideRef.current();
    } else {
      hidePopover();
    }
  }, [hidePopover, prepareFocusReturn]);
  const handleTriggerFocus = useCallback(_event => {
    onFocusReturnTargetFocus();
    if (!isSheetOpenRef.current && activePresentationRef.current === 'bottom-sheet') {
      // BottomSheet focuses finalFocusRef only after its exit completes. That
      // focus event is the lifecycle signal that the retained sheet can now
      // leave the tree without dropping focus to the document body.
      setIsSheetPresented(false);
    }
  }, [onFocusReturnTargetFocus]);
  const handleSheetOpenChange = useCallback(nextIsOpen => {
    if (nextIsOpen) {
      show();
    } else {
      hide();
    }
  }, [hide, show]);
  const isOpen = popover.isOpen || isSheetOpen;
  const activePresentation = isOpen || isSheetPresented ? activePresentationRef.current : resolvedPresentation;
  return {
    activePresentation,
    hide,
    isOpen,
    isSheetOpen,
    isSheetPresented,
    isTriggerFocusRingSuppressed: isFocusRingSuppressed,
    onSheetOpenChange: handleSheetOpenChange,
    onTriggerFocus: handleTriggerFocus,
    popover,
    show
  };
}