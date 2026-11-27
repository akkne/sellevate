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

it("plays successive MP3 bytes on one source and closes it after the last append", () => {
    const complete = vi.fn();
    const appendBuffer = vi.fn(() => { buffer.updating = true; });
    const buffer = { updating: false, appendBuffer, onupdateend: () => {} };
    class FakeSource extends EventTarget {
        readyState = "open";
        addSourceBuffer = () => buffer;
        endOfStream = vi.fn();
        constructor() { super(); source = this; }
    }
    let source!: FakeSource;
    vi.stubGlobal("MediaSource", FakeSource);
    const player = new CallAudioPlayer({ onPlaybackEnd: complete });
    const first = new ArrayBuffer(3);
    const second = new ArrayBuffer(4);
    player.beginQueue();
    player.enqueueMp3Segment(first);
    source.dispatchEvent(new Event("sourceopen"));
    player.enqueueMp3Segment(second);
    player.markQueueComplete();
    expect(appendBuffer.mock.calls).toHaveLength(1);
    buffer.updating = false;
    buffer.onupdateend();
    expect(appendBuffer.mock.calls).toEqual([[first], [second]]);
    expect(source.endOfStream).not.toHaveBeenCalled();
    buffer.updating = false;
    buffer.onupdateend();
    expect(source.endOfStream).toHaveBeenCalledOnce();
    expect(play).toHaveBeenCalledOnce();
    expect(complete).not.toHaveBeenCalled();
    media.dispatchEvent(new Event("ended"));
    expect(complete).toHaveBeenCalledOnce();
    player.destroy();
});
