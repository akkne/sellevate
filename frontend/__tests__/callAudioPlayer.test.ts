import { afterEach, beforeEach, expect, it, vi } from "vitest";
import { CallAudioPlayer } from "@/features/voice/services/call-audio-player";

let media: HTMLAudioElement;
const play = vi.fn<() => Promise<void>>();
const revoke = vi.fn();
let sequence = 0;

beforeEach(() => {
    media = document.createElement("audio");
    media.play = play.mockReset().mockResolvedValue(undefined);
    media.pause = vi.fn();
    media.load = vi.fn();
    sequence = 0;
    vi.stubGlobal("Audio", class { constructor() { return media; } });
    vi.stubGlobal("URL", class {
        static createObjectURL = () => `blob:voice-${++sequence}`;
        static revokeObjectURL = revoke.mockClear();
    });
});

afterEach(() => {
    media.remove();
    vi.unstubAllGlobals();
});

it("plays streamed sentences on the element authorized at pickup and waits for the last one", async () => {
    const complete = vi.fn();
    const player = new CallAudioPlayer({ onPlaybackEnd: complete });
    await player.preparePlayback();
    expect(media.isConnected).toBe(true);
    expect(media.getAttribute("src")).toBe("/audio/call-ready.wav");
    player.beginQueue();
    player.enqueue(new ArrayBuffer(8));
    player.enqueue(new ArrayBuffer(8));
    player.markQueueComplete();
    expect(media.getAttribute("src")).toBe("blob:voice-1");
    media.dispatchEvent(new Event("ended"));
    expect(complete).not.toHaveBeenCalled();
    expect(media.getAttribute("src")).toBe("blob:voice-2");
    media.dispatchEvent(new Event("ended"));
    expect(complete).toHaveBeenCalledOnce();
    expect(revoke.mock.calls).toEqual([["blob:voice-1"], ["blob:voice-2"]]);
    player.destroy();
    expect(media.isConnected).toBe(false);
});

it("ignores a play rejection from a call that has been stopped", async () => {
    const error = vi.fn();
    const player = new CallAudioPlayer({ onError: error });
    let reject!: (reason: Error) => void;
    play.mockImplementationOnce(() => new Promise<void>((_, fail) => { reject = fail; }));
    player.beginQueue();
    player.enqueue(new ArrayBuffer(8));
    player.stop();
    reject(new Error("aborted"));
    await Promise.resolve();
    expect(error).not.toHaveBeenCalled();
});
