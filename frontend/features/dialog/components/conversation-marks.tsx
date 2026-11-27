import type { CSSProperties } from "react";

/** Two offset quotation strokes, used as the assistant's signature throughout text chat. */
export function DialogueMark() {
    return <span className="dialogue-mark" aria-hidden="true" />;
}

const signalHeights = [9, 13, 20, 32, 47, 60, 46, 28, 16, 12, 19, 38, 65, 88, 100, 84, 58, 34, 18, 12, 17, 30, 47, 56, 43, 27, 17, 12, 8];

export function VoiceSignal({ small = false }: { small?: boolean }) {
    const heights = small ? [36, 72, 100, 58, 30] : signalHeights;
    return (
        <span className={small ? "voice-signal voice-signal--small" : "voice-signal"} aria-hidden="true">
            {heights.map((height, index) => (
                <i key={index} style={{ height: `${height}%`, "--beat-delay": `${-(index % 7) * 0.13}s` } as CSSProperties} />
            ))}
        </span>
    );
}
