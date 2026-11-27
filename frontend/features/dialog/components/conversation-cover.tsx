"use client";

import { DialogueMark, VoiceSignal } from "./conversation-marks";
import { useHydrated } from "@/shared/hooks/use-hydrated";

interface ConversationCoverProps {
    variant: "chat" | "voice";
    title?: string;
    description?: string | null;
    compact?: boolean;
}

export function ConversationCover({ variant, title, description, compact = false }: ConversationCoverProps) {
    const hydrated = useHydrated();
    const english = hydrated && navigator.language.toLowerCase().startsWith("en");
    const voice = variant === "voice";
    const label = voice ? (english ? "Voice call" : "Голосовой звонок") : (english ? "AI chat" : "Чат с ИИ");
    const displayTitle = title || (english ? "Start the conversation" : "Начни разговор");
    const detail = description || (!voice && (english ? "Introduce yourself and tell the customer why you’re calling." : "Представься и расскажи клиенту, почему звонишь."));
    return (
        <header className={`conversation-cover conversation-cover--${variant}${compact ? " is-compact" : ""}`}>
            <div className="conversation-copy">
                <span className="conversation-medium">{label}</span>
                <h1 className="conversation-title">{displayTitle}</h1>
                {detail && !compact && <p className="conversation-detail">{detail}</p>}
            </div>
            {voice ? <VoiceSignal /> : <DialogueMark />}
        </header>
    );
}
