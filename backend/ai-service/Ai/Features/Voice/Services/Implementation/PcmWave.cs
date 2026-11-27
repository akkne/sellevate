namespace Sellevate.Ai.Features.Voice.Services.Implementation;

internal static class PcmWave
{
    /// <summary>
    /// Writes the 44-byte canonical RIFF/WAVE header in front of raw little-endian PCM so a browser
    /// can play the bytes without knowing how they were sampled.
    /// </summary>
    internal static byte[] Encode(byte[] pcm, int sampleRate)
    {
        const short channels = 1;
        const short bitsPerSample = 16;
        const short pcmFormatTag = 1;
        const int bitsPerByte = 8;
        const int formatChunkSize = 16;
        const int headerBytes = 44;
        const int bytesBeforeRiffSizeField = 8;

        var byteRate = sampleRate * channels * bitsPerSample / bitsPerByte;
        var blockAlign = (short)(channels * bitsPerSample / bitsPerByte);

        using var memoryStream = new MemoryStream(headerBytes + pcm.Length);
        using var writer = new BinaryWriter(memoryStream);
        writer.Write("RIFF"u8);
        writer.Write(headerBytes - bytesBeforeRiffSizeField + pcm.Length);
        writer.Write("WAVE"u8);
        writer.Write("fmt "u8);
        writer.Write(formatChunkSize);
        writer.Write(pcmFormatTag);
        writer.Write(channels);
        writer.Write(sampleRate);
        writer.Write(byteRate);
        writer.Write(blockAlign);
        writer.Write(bitsPerSample);
        writer.Write("data"u8);
        writer.Write(pcm.Length);
        writer.Write(pcm);
        return memoryStream.ToArray();
    }
}
