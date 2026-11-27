"use client";

import { useState, FormEvent } from "react";
import { Icon } from "@/shared/components/icon";
import { useHydrated } from "@/shared/hooks/use-hydrated";

interface ChatInputProps {
    // Returns whether the send actually succeeded. The composer clears the draft as soon as
    // the send starts (so it doesn't sit on screen next to its own optimistic bubble for the
    // whole round-trip) and restores it on `false` (or a caller that never resolves it) so a
    // rejected send never looks like it went out (docs/AUDIT_SILENT_WRITES.md W-5).
    onSend: (content: string) => Promise<boolean>;
    disabled: boolean;
    ended?: boolean;
}

export function ChatInput({ onSend, disabled, ended = false }: ChatInputProps) {
    const hydrated = useHydrated();
    const english = hydrated && navigator.language.toLowerCase().startsWith("en");
    const placeholder = ended ? (english ? "Conversation ended" : "Диалог завершён") : (english ? "Write a message…" : "Напиши сообщение…");
    const [inputValue, setInputValue] = useState("");

    const handleSubmit = async (submitEvent: FormEvent) => {
        submitEvent.preventDefault();
        const trimmedValue = inputValue.trim();
        if (!trimmedValue || disabled) return;

        setInputValue("");
        const succeeded = await onSend(trimmedValue);
        if (!succeeded) setInputValue(trimmedValue);
    };

    const canSend = !disabled && inputValue.trim().length > 0;

    return (
        <form onSubmit={handleSubmit} className="dc-input-row">
            <textarea
                rows={2}
                value={inputValue}
                onChange={(event) => setInputValue(event.target.value)}
                onKeyDown={(event) => {
                    if (event.key === "Enter" && !event.shiftKey && !event.nativeEvent.isComposing && event.nativeEvent.keyCode !== 229) {
                        event.preventDefault();
                        event.currentTarget.form?.requestSubmit();
                    }
                }}
                disabled={disabled}
                placeholder={placeholder}
                className="dc-draft"
                aria-label={english ? "Message" : "Сообщение"}
            />
            <button type="submit" disabled={!canSend} aria-label={english ? "Send" : "Отправить"} className="dc-send">
                <Icon name="send" size={22} />
            </button>
        </form>
    );
}
