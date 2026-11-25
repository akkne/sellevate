"use client";

import { useEffect } from "react";

/**
 * Binds the Enter key (window-level) to the primary action of the current
 * screen — submit, continue, next card. Pass `null` to disable while the
 * action is unavailable (nothing selected yet, submission in flight).
 *
 * Guards:
 * - held-key repeats are ignored, so one long press can't blast through
 *   several screens in a row;
 * - presses while a button/link is focused are ignored — the browser already
 *   "clicks" the focused element, handling it here too would double-fire;
 * - inside a textarea plain Enter keeps its typing behavior (the field itself
 *   decides what Enter means); Ctrl/Cmd+Enter triggers the action instead.
 */
export function useEnterAction(action: (() => void) | null) {
    useEffect(() => {
        function handleKeyDown(keyboardEvent: KeyboardEvent) {
            if (keyboardEvent.key !== "Enter" || keyboardEvent.repeat || keyboardEvent.defaultPrevented) return;
            if (!action) return;
            const target = keyboardEvent.target;
            if (target instanceof HTMLButtonElement || target instanceof HTMLAnchorElement) return;
            if (target instanceof HTMLTextAreaElement && !keyboardEvent.ctrlKey && !keyboardEvent.metaKey) return;
            keyboardEvent.preventDefault();
            action();
        }
        window.addEventListener("keydown", handleKeyDown);
        return () => window.removeEventListener("keydown", handleKeyDown);
    }, [action]);
}
