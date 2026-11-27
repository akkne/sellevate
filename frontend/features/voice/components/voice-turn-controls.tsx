"use client";

import { useHydrated } from "@/shared/hooks/use-hydrated";
import type { VoiceTurnMode } from "@/features/voice/services/speech-endpointer";

interface VoiceTurnControlsProps {
    mode: VoiceTurnMode;
    onChange: (mode: VoiceTurnMode) => void;
    onSend: () => void;
    active: boolean;
    canSend: boolean;
    pauseSeconds: number;
}

export function VoiceTurnControls({ mode, onChange, onSend, active, canSend, pauseSeconds }: VoiceTurnControlsProps) {
    const hydrated = useHydrated();
    const english = hydrated && navigator.language.toLowerCase().startsWith("en");
    const label = english ? "Send replies" : "Отправка реплик";
    const manual = mode === "manual";
    const choices = { manual: english ? "By button" : "По кнопке", pause: english ? "After a pause" : "По паузе" };
    const delay = pauseSeconds.toLocaleString(english ? "en" : "ru");
    return (
        <div className="flex flex-none flex-wrap items-center justify-between gap-3 rounded-2xl border border-line bg-surface p-3 sm:px-5">
            <div className="flex flex-wrap items-center gap-x-4 gap-y-2">
                <span className="text-sm font-semibold text-ink-2">{label}</span>
                <div role="group" aria-label={label} className="inline-flex rounded-xl bg-surface-3 p-1">
                    {(["manual", "pause"] as const).map(choice => (
                        <button key={choice} type="button" aria-pressed={mode === choice} onClick={() => onChange(choice)}
                            className="min-h-11 rounded-lg px-3 text-sm font-semibold text-ink-2 aria-pressed:bg-surface aria-pressed:text-ink-heading aria-pressed:shadow-sm focus-visible:outline-2">
                            {choices[choice]}
                        </button>
                    ))}
                </div>
            </div>
            {manual && active && (
                <button type="button" onClick={onSend} disabled={!canSend}
                    className="min-h-11 rounded-xl bg-ink px-5 font-semibold text-surface disabled:bg-surface-3 disabled:text-ink-3 focus-visible:outline-2 focus-visible:outline-offset-2">
                    {english ? "Send reply" : "Отправить реплику"}
                </button>
            )}
            {!manual && <span className="text-sm text-ink-2">{english ? `Pause: ${delay} s` : `Пауза ${delay} с`}</span>}
        </div>
    );
}
