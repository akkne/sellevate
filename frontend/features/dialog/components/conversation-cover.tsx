"use client";

import { Icon } from "@/shared/components/icon";
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
            <div className="relative z-1 max-w-[52ch]">
                <div className="flex items-center gap-2 text-sm font-semibold text-white/85">
                    <Icon name={voice ? "phone" : "message"} size={16} />
                    {label}
                </div>
                <h1 className="conversation-title">{displayTitle}</h1>
                {detail && !compact && <p className="mt-3 max-w-[52ch] text-base leading-relaxed text-white/90 sm:text-lg">{detail}</p>}
            </div>
        </header>
    );
}
