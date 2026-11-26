const coverArt: ReadonlyMap<string, string> = new Map([
    ["sales-basics", "bg-[url('/skill-covers/contours.webp')]"],
    ["customer-questions", "bg-[url('/skill-covers/moire.webp')]"],
    ["next-step", "bg-[url('/skill-covers/strata.webp')]"],
]);

export function SkillCover({ slug, title, stage, progress, progressLabel, heading: Heading }: {
    slug: string;
    title: string;
    stage: string;
    progress: number;
    progressLabel: string;
    heading: "h1" | "h2";
}) {
    const art = coverArt.get(slug) ?? "bg-[url('/skill-covers/contours.webp')]";

    return (
        <header className="relative isolate overflow-hidden rounded-[24px] bg-path-forest text-white sm:rounded-[30px]">
            <div aria-hidden="true" className={`pointer-events-none absolute inset-y-0 right-0 -z-1 w-[47%] bg-size-[100%_100%] bg-no-repeat ${art}`} />
            <div className="relative flex min-h-[212px] flex-col items-start justify-between gap-6 p-6 sm:min-h-[255px] sm:px-9 sm:py-8 xl:min-h-[278px] xl:px-10">
                {stage && <span className="inline-flex max-w-full items-center gap-2 text-xs font-semibold tracking-wide text-white/85">
                    <span className="size-2 shrink-0 rounded-full bg-primary" />{stage}
                </span>}
                <Heading className="max-w-full text-[clamp(2.15rem,4.1vw,4.25rem)] leading-[1.02] font-bold tracking-[-.045em] text-balance [overflow-wrap:anywhere] sm:max-w-[72%]">{title}</Heading>
                <div className="w-[46%] max-w-72 sm:w-[56%]">
                    <div className="mb-2 flex items-baseline justify-between gap-2 text-xs font-semibold">
                        <span className="text-white/80">{progressLabel}</span><span>{progress}%</span>
                    </div>
                    <progress aria-label={progressLabel} className="path-cover-progress block h-1.5 w-full overflow-hidden rounded-full" max="100" value={progress} />
                </div>
            </div>
        </header>
    );
}
