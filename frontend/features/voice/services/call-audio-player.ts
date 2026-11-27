import type { AudioPlayerOptions } from "./audio-player";

export class CallAudioPlayer {
    private readonly audio = new Audio();
    private readonly pending: Blob[] = [];
    private currentUrl: string | null = null;
    private streamComplete = false;
    private prepared = false;
    private failed = false;

    private mediaSource: MediaSource | null = null;
    private sourceBuffer: SourceBuffer | null = null;
    private readonly segments: ArrayBuffer[] = [];

    static supportsProgressiveMp3(): boolean {
        return typeof MediaSource !== "undefined" && MediaSource.isTypeSupported("audio/mpeg");
    }

    constructor(private readonly options: AudioPlayerOptions) {}

    async preparePlayback(): Promise<void> {
        if (this.prepared) return;
        if (!this.audio.isConnected) {
            this.audio.hidden = true;
            document.body.appendChild(this.audio);
        }
        // Authorize the same element that will play the reply after the network round trip.
        this.audio.src = "/audio/call-ready.wav";
        await this.audio.play();
        this.prepared = true;
    }

    beginQueue(): void {
        this.stop();
        this.options.onStateChange?.("loading");
    }

    enqueue(bytes: ArrayBuffer): void {
        if (this.failed || !bytes.byteLength) return;
        const riff = new Uint8Array(bytes, 0, Math.min(4, bytes.byteLength));
        const wav = String.fromCharCode(...riff) === "RIFF";
        this.pending.push(new Blob([bytes], { type: wav ? "audio/wav" : "audio/mpeg" }));
        if (!this.currentUrl) this.playNext();
    }

    enqueueMp3Segment(bytes: ArrayBuffer): void {
        if (this.failed || !bytes.byteLength) return;
        this.segments.push(bytes);
        if (!this.mediaSource) {
            const source = new MediaSource();
            this.mediaSource = source;
            source.addEventListener("sourceopen", () => {
                if (source !== this.mediaSource) return;
                try {
                    this.sourceBuffer = source.addSourceBuffer("audio/mpeg");
                    this.sourceBuffer.onupdateend = () => this.appendNext();
                    this.sourceBuffer.onerror = () => this.audio.onerror?.(new Event("error"));
                    this.appendNext();
                } catch {
                    this.audio.onerror?.(new Event("error"));
                }
            }, { once: true });
            this.playUrl(URL.createObjectURL(source));
        } else {
            this.appendNext();
        }
    }

    private appendNext(): void {
        if (!this.sourceBuffer || this.sourceBuffer.updating || this.mediaSource?.readyState !== "open") return;
        try {
            const bytes = this.segments.shift();
            if (bytes) this.sourceBuffer.appendBuffer(bytes);
            else if (this.streamComplete) this.mediaSource.endOfStream();
        } catch {
            this.audio.onerror?.(new Event("error"));
        }
    }

    markQueueComplete(): void {
        this.streamComplete = true;
        if (this.mediaSource) this.appendNext();
        if (!this.currentUrl && !this.failed) this.playNext();
    }

    private playNext(): void {
        const next = this.pending.shift();
        if (!next) {
            if (this.streamComplete) {
                this.options.onStateChange?.("ended");
                this.options.onPlaybackEnd?.();
            }
            return;
        }

        this.playUrl(URL.createObjectURL(next));
    }

    private playUrl(url: string): void {
        this.currentUrl = url;
        this.audio.src = url;
        this.audio.onplaying = () => {
            if (this.currentUrl === url) this.options.onStateChange?.("playing");
        };
        this.audio.onended = () => {
            if (this.currentUrl !== url) return;
            this.releaseSource();
            this.playNext();
        };
        const reportError = () => {
            if (this.currentUrl !== url) return;
            this.stop();
            this.failed = true;
            this.options.onStateChange?.("error");
            const english = navigator.language.toLowerCase().startsWith("en");
            this.options.onError?.(new Error(english ? "Could not play the spoken reply" : "Не удалось воспроизвести голосовой ответ"));
        };
        this.audio.onerror = reportError;
        void this.audio.play().catch(reportError);
    }

    private releaseSource(): void {
        this.mediaSource = null;
        if (this.sourceBuffer) {
            this.sourceBuffer.onupdateend = null;
            this.sourceBuffer.onerror = null;
            this.sourceBuffer = null;
        }
        this.segments.length = 0;
        this.audio.onplaying = null;
        this.audio.onended = null;
        this.audio.onerror = null;
        if (this.currentUrl) URL.revokeObjectURL(this.currentUrl);
        this.currentUrl = null;
    }

    stop(): void {
        this.releaseSource();
        this.audio.pause();
        this.pending.length = 0;
        this.streamComplete = false;
        this.failed = false;
    }

    destroy(): void {
        this.stop();
        this.audio.removeAttribute("src");
        this.audio.load();
        this.audio.remove();
    }
}
