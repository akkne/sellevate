"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { useSkillTree, useSkills, useSkillStages, type SkillTreeNode } from "@/features/skills/hooks/use-skill-tree";
import { useLessonsForSkill } from "@/features/exercise/hooks/use-lesson";
import { useSelectedSkillStore } from "@/shared/stores/selected-skill-store";
import { useOnboardingSkillSelectionStore } from "@/shared/stores/onboarding-skill-selection-store";
import { Icon, type IconName } from "@/shared/components/icon";
import { ErrorState } from "@/shared/components/error-state";
import { ActiveAssignmentCard } from "@/features/assignments/components/active-assignment-card";
import { getStageMeta } from "@/features/skills/constants/skill-stages";
import type { LessonSummary } from "@/features/exercise/hooks/use-lesson";

// ─── Chip color map from DESIGN_SPEC §1.1 ───────────────────────────────────
const CHIP_MAP: Record<string, { bg: string; color: string }> = {
    choice:     { bg: "#EAF2FF", color: "#2F6FE0" },
    blank:      { bg: "#E2F8F0", color: "#0E9F6E" },
    reorder:    { bg: "#FFF1E8", color: "#D9722E" },
    match:      { bg: "#F1ECFB", color: "#6C5BD9" },
    categorize: { bg: "#FDEBF3", color: "#C44E8A" },
    spot:       { bg: "#FDECEA", color: "#D9503E" },
    rewrite:    { bg: "#EAF6F8", color: "#1E8AA0" },
    dialogue:   { bg: "#EEF0FE", color: "#4658D6" },
    evaluate:   { bg: "#F4F0E6", color: "#9A7B2E" },
    free:       { bg: "#EFEFF2", color: "#6A6A72" },
    theory:     { bg: "#E7FCC6", color: "#4A7C00" },
    practice:   { bg: "#E2F8F0", color: "#0E9F6E" },
};

function chipStyle(kind: string) {
    return CHIP_MAP[kind] ?? CHIP_MAP.free;
}

// ─── Spinner ────────────────────────────────────────────────────────────────
function Spinner() {
    return (
        <div
            aria-label="Загрузка"
            style={{
                width: 36,
                height: 36,
                borderRadius: "50%",
                border: "3px solid var(--primary-soft)",
                borderTopColor: "var(--primary)",
                animation: "spin 0.8s linear infinite",
            }}
        />
    );
}

const stageIcons: Record<string, IconName> = {
    preparation: "compass",
    discovery: "search",
    engagement: "message",
    closing: "target",
    retention: "users",
};

function PathSkillList({ onSelected }: { onSelected?: () => void }) {
    const { data: allSkills, isLoading, isLoadingError, refetch } = useSkills();
    const { stages } = useSkillStages();
    const { selectedSkill, setSelectedSkill } = useSelectedSkillStore();

    const enrolledSkills = (allSkills ?? []).filter((s) => s.status !== "locked");

    // Auto-select the skill the user is currently working on; also recover when the
    // stored selection points to a skill that is no longer enrolled.
    useEffect(() => {
        if (enrolledSkills.length === 0) return;
        const stillEnrolled = selectedSkill && enrolledSkills.some((s) => s.slug === selectedSkill.slug);
        if (!stillEnrolled) {
            const first = enrolledSkills.find((s) => s.status === "in_progress") ?? enrolledSkills[0];
            setSelectedSkill({ slug: first.slug, title: first.title, iconName: first.iconName });
        }
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [allSkills]);

    if (isLoading) {
        return (
            <>
                {[1, 2, 3].map((i) => (
                    <div
                        key={i}
                        style={{
                            height: 44,
                            borderRadius: 9,
                            background: "var(--surface-3)",
                            marginBottom: 6,
                            animation: "pulse 2s ease-in-out infinite",
                        }}
                    />
                ))}
            </>
        );
    }

    // R-6: gate on isLoadingError (first load, no data at all) rather than bare isError — a
    // failed background refetch of an already-populated skill list must not blank out the
    // already-rendered accordion.
    if (isLoadingError) {
        return (
            <ErrorState
                compact
                title="Не удалось загрузить навыки"
                message="Список навыков не загрузился — это не значит, что записей на навыки нет."
                onRetry={() => refetch()}
            />
        );
    }

    if (enrolledSkills.length === 0) {
        return (
            <p style={{ fontSize: 13, color: "var(--ink-3)", textAlign: "center", paddingTop: 20, lineHeight: 1.5 }}>
                Нет активных навыков.{" "}
                <Link href="/profile" style={{ color: "var(--primary-ink)", fontWeight: 600 }}>
                    Добавить в профиле
                </Link>
            </p>
        );
    }

    return (
        <ul className="m-0 grid list-none gap-1.5 p-0">
            {enrolledSkills.map((skill) => {
                const selected = selectedSkill?.slug === skill.slug;
                const stage = getStageMeta(skill.stage, stages);
                const icon = skill.status === "completed" ? "check" : stageIcons[stage.key] ?? "book";

                return (
                    <li key={skill.skillId}>
                        <button
                            type="button"
                            aria-pressed={selected}
                            className="group flex min-h-16 w-full items-center gap-3 rounded-2xl px-3 py-3 text-left text-ink-heading transition-colors hover:bg-surface-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-ink aria-pressed:bg-primary-soft motion-reduce:transition-none"
                            onClick={() => {
                                setSelectedSkill({ slug: skill.slug, title: skill.title, iconName: skill.iconName });
                                onSelected?.();
                            }}
                        >
                            <span className="grid size-9 shrink-0 place-items-center rounded-full bg-surface-3 text-ink-3 group-aria-pressed:bg-primary group-aria-pressed:text-on-primary">
                                <Icon name={icon} size={18} />
                            </span>
                            <span className="min-w-0 flex-1">
                                <span className="block text-[15px] leading-tight font-bold [overflow-wrap:anywhere]">{skill.title}</span>
                                {skill.stage && (
                                    <span className="mt-1 block text-xs leading-snug text-ink-3">{stage.label}</span>
                                )}
                            </span>
                            <span className="shrink-0 text-xs font-semibold text-ink-3 tabular-nums">
                                {skill.completedLessonCount}/{skill.totalLessonCount}
                            </span>
                        </button>
                    </li>
                );
            })}
        </ul>
    );
}

// ─── Overall path progress (skills mastered across the whole path) ──────────
function PathOverallProgress() {
    const { data: allSkills, isLoadingError } = useSkills();
    const enrolled = (allSkills ?? []).filter((s) => s.status !== "locked");

    // E-5/E-12: this used to just disappear (`return null`) on a failed /skills fetch, same as
    // "no enrolled skills" — the skill list right below already explains the failure with a
    // retry, so here a narrow note is enough to stop the progress bar's disappearance from
    // reading as "progress was reset".
    // R-6: gated on isLoadingError, not bare isError — a background refetch failure must not
    // hide an already-computed, still-valid progress bar behind this note.
    if (isLoadingError) {
        return (
            <p style={{ fontSize: 12, color: "var(--ink-4)", padding: "0 2px 10px" }}>
                Общий прогресс не загрузился.
            </p>
        );
    }

    if (enrolled.length === 0) return null;

    const doneCount = enrolled.filter(
        (s) => s.totalLessonCount > 0 && s.completedLessonCount === s.totalLessonCount
    ).length;
    const pct = Math.round((doneCount / enrolled.length) * 100);

    return (
        <div className="path-overall">
            <div className="path-overall-row">
                <span className="path-overall-label">Освоено навыков</span>
                <span className="path-overall-count">{doneCount}/{enrolled.length}</span>
            </div>
            <div className="path-overall-bar" role="progressbar" aria-valuenow={pct} aria-valuemin={0} aria-valuemax={100}>
                <div
                    className={"path-overall-fill" + (pct === 100 ? " complete" : "")}
                    style={{ width: `${pct}%` }}
                />
            </div>
        </div>
    );
}

function PathLeftColumn() {
    return (
        <aside className="path-left">
            <h2 className="mx-5 mt-7 mb-1 text-[21px] leading-tight font-extrabold tracking-tight text-ink-heading">Путь обучения</h2>
            <PathOverallProgress />

            <div className="min-h-0 flex-1 overflow-y-auto px-3 pt-3 pb-6">
                <PathSkillList />
            </div>
        </aside>
    );
}

// ─── Mobile skill picker: sticky bar + bottom sheet (≤767px) ────────────────
function PathMobilePicker({ activeStageLabel }: { activeStageLabel: string | undefined }) {
    const [isSheetOpen, setSheetOpen] = useState(false);
    const { data: allSkills } = useSkills();
    const { selectedSkill } = useSelectedSkillStore();
    const skillNode = allSkills?.find((s) => s.slug === selectedSkill?.slug);

    return (
        <>
            <button
                className="path-mob-picker"
                onClick={() => setSheetOpen(true)}
                aria-haspopup="dialog"
                aria-expanded={isSheetOpen}
            >
                <span className="path-mob-picker-body">
                    <span className="path-mob-picker-eyebrow">{activeStageLabel ?? "Путь обучения"}</span>
                    <span className="path-mob-picker-title">{selectedSkill?.title ?? "Выбери навык"}</span>
                </span>
                {skillNode && skillNode.totalLessonCount > 0 && (
                    <span className="path-mob-picker-count">
                        {skillNode.completedLessonCount}/{skillNode.totalLessonCount}
                    </span>
                )}
                <span className="path-mob-picker-chev" aria-hidden="true">
                    <Icon name="chevron-down" size={16} />
                </span>
            </button>

            {isSheetOpen && (
                <>
                    <div className="path-sheet-overlay" aria-hidden onClick={() => setSheetOpen(false)} />
                    <div className="path-sheet" role="dialog" aria-label="Выбор навыка">
                        <div className="path-sheet-head">
                            <span className="path-sheet-title">Путь обучения</span>
                            <button className="icon-btn" onClick={() => setSheetOpen(false)} aria-label="Закрыть">
                                <Icon name="close" size={16} />
                            </button>
                        </div>
                        <div className="path-sheet-scroll">
                            <PathOverallProgress />
                            <PathSkillList onSelected={() => setSheetOpen(false)} />
                        </div>
                    </div>
                </>
            )}
        </>
    );
}

// ─── Lesson timeline node label ──────────────────────────────────────────────
function TimelineNodeLabel({ lesson, index }: { lesson: LessonSummary; index: number }) {
    if (lesson.status === "completed") return <>✓</>;
    if (lesson.status === "locked") return <Icon name="lock" size={13} />;
    return <>{index + 1}</>;
}

function lessonNodeClass(status: LessonSummary["status"]) {
    if (status === "completed") return "path-tl-node done";
    if (status === "in_progress") return "path-tl-node in-progress";
    if (status === "available") return "path-tl-node available";
    return "path-tl-node locked";
}

function lessonStatusLabel(status: LessonSummary["status"]) {
    if (status === "completed") return "Завершён";
    if (status === "in_progress") return "В процессе";
    if (status === "available") return "Доступен";
    return "Заблокирован";
}

function lessonStatusClass(status: LessonSummary["status"]) {
    if (status === "completed") return "path-tl-status done";
    if (status === "in_progress") return "path-tl-status in-progress";
    return "path-tl-status available";
}

function lessonActionLabel(lesson: LessonSummary) {
    if (lesson.status === "completed") return "Повторить";
    if (lesson.status === "in_progress") return "Продолжить";
    return "Начать";
}

// ─── Center column: skill detail + lesson timeline ───────────────────────────
function PathCenterColumn({
    skillSlug,
    skillTitle,
    stageLabel,
    allSkills,
}: {
    skillSlug: string;
    skillTitle: string;
    stageLabel: string;
    allSkills: SkillTreeNode[];
}) {
    const { data: lessons, isLoading, isLoadingError, refetch } = useLessonsForSkill(skillSlug);

    const sorted = (lessons ?? [])
        .slice()
        .sort((a, b) => a.topicOrder - b.topicOrder || a.orderInTopic - b.orderInTopic);
    const completedLessons = sorted.filter((l) => l.status === "completed");
    const completedCount = completedLessons.length;
    const totalCount = sorted.length;
    const progressPct = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;

    // Real aggregate accuracy: average of bestScore over completed lessons.
    const avgAccuracy = completedLessons.length > 0
        ? Math.round(completedLessons.reduce((sum, l) => sum + l.bestScore, 0) / completedLessons.length)
        : null;
    const remainingCount = totalCount - completedCount;

    // Skill node data for the header status
    const skillNode = allSkills.find((s) => s.slug === skillSlug);
    const skillStatus = skillNode?.status ?? "available";

    function skillStatusLabel(s: typeof skillStatus) {
        if (s === "completed") return "Освоено";
        if (s === "in_progress") return "В процессе";
        return "Доступен";
    }
    function skillStatusClass(s: typeof skillStatus) {
        if (s === "completed") return "path-skill-status done";
        if (s === "in_progress") return "path-skill-status in-progress";
        return "path-skill-status available";
    }

    // FAB: first resumable/available lesson
    const fabLesson = sorted.find((l) => l.status === "in_progress" || l.status === "available");

    const scrollRef = useRef<HTMLDivElement | null>(null);
    const activeItemRef = useRef<HTMLDivElement | null>(null);
    const [isFabVisible, setFabVisible] = useState(true);

    // When switching skills, bring the current lesson into view instead of making
    // the user scroll past all completed ones.
    useEffect(() => {
        const container = scrollRef.current;
        const target = activeItemRef.current;
        if (!container || !target) return;
        const delta = target.getBoundingClientRect().top - container.getBoundingClientRect().top;
        if (delta > container.clientHeight * 0.6) {
            container.scrollTo({ top: container.scrollTop + delta - container.clientHeight / 3 });
        }
    }, [skillSlug, isLoading]);

    // Hide the floating bar while the active lesson card is already on screen —
    // otherwise it just duplicates the card's own button and covers content.
    useEffect(() => {
        const target = activeItemRef.current;
        if (!target) return;
        const observer = new IntersectionObserver(
            ([entry]) => setFabVisible(!entry.isIntersecting),
            { threshold: 0.4 }
        );
        observer.observe(target);
        return () => observer.disconnect();
    }, [skillSlug, isLoading, fabLesson?.lessonId]);

    return (
        <div className="path-center">
            <div className="path-center-scroll" ref={scrollRef}>
                {/* R-6: isLoadingError (no data yet), not bare isError — a background refetch
                    failure here used to blank out the whole center column, including an
                    already-rendered lesson timeline and stats, over a transient failure. */}
                {isLoadingError ? (
                    <div style={{ display: "flex", alignItems: "center", justifyContent: "center", minHeight: 320 }}>
                        <ErrorState
                            title="Не удалось загрузить уроки навыка"
                            message="Статистика и уроки этого навыка не загрузились. Это не значит, что прогресс пропал — попробуй ещё раз."
                            onRetry={() => refetch()}
                        />
                    </div>
                ) : (
                <>
                {/* Breadcrumb */}
                <nav className="path-breadcrumb" aria-label="Навигация по разделам">
                    <span className="path-bc-stage">{stageLabel}</span>
                    <span className="path-bc-chev" aria-hidden="true">
                        <Icon name="chevron-right" size={13} />
                    </span>
                    <span className="path-bc-skill">{skillTitle}</span>
                    <span className="path-bc-meta">
                        {completedCount} / {totalCount} уроков
                    </span>
                </nav>

                {/* Skill header card */}
                <div className="path-skill-header">
                    <div className="path-skill-header-top">
                        <div style={{ minWidth: 0 }}>
                            <h1 className="path-skill-header-title">{skillTitle}</h1>
                            {/* Summary: omitted — backend SkillTreeNode has no description field */}
                        </div>
                        <span className={skillStatusClass(skillStatus)}>
                            {skillStatusLabel(skillStatus)}
                        </span>
                    </div>

                    {/* Progress bar */}
                    <div className="path-prog-row">
                        <span className="path-prog-pct">{progressPct}%</span>
                        <div className="path-prog-bar" role="progressbar" aria-valuenow={progressPct} aria-valuemin={0} aria-valuemax={100}>
                            <div
                                className={"path-prog-fill" + (progressPct === 100 ? " complete" : "")}
                                style={{ width: `${progressPct}%` }}
                            />
                        </div>
                    </div>

                    {/* 4-cell stat grid */}
                    <div className="path-stat-grid" role="list">
                        <div className="path-stat-cell" role="listitem">
                            <div className="path-stat-label">Уроки</div>
                            <div className="path-stat-val">{totalCount}</div>
                        </div>
                        <div className="path-stat-cell" role="listitem">
                            <div className="path-stat-label">Завершено</div>
                            <div className="path-stat-val">{completedCount}</div>
                        </div>
                        <div className="path-stat-cell" role="listitem">
                            <div className="path-stat-label">Точность</div>
                            {/* average bestScore over completed lessons; dash until something is completed */}
                            <div className="path-stat-val" aria-label={avgAccuracy === null ? "Нет данных" : undefined}>
                                {avgAccuracy === null ? "—" : `${avgAccuracy}%`}
                            </div>
                        </div>
                        <div className="path-stat-cell" role="listitem">
                            <div className="path-stat-label">Осталось</div>
                            <div className="path-stat-val">{remainingCount}</div>
                        </div>
                    </div>
                </div>

                {/* Lessons timeline */}
                {isLoading ? (
                    <div style={{ display: "flex", justifyContent: "center", padding: "40px 0" }}>
                        <Spinner />
                    </div>
                ) : sorted.length === 0 ? (
                    <div style={{ textAlign: "center", padding: "48px 0", color: "var(--ink-4)" }}>
                        <div style={{ fontSize: 32, marginBottom: 12 }}>📂</div>
                        <p style={{ fontSize: 14, fontWeight: 600, marginBottom: 6 }}>Уроки пока не добавлены</p>
                        <p style={{ fontSize: 13, color: "var(--ink-4)" }}>Попроси администратора добавить уроки</p>
                    </div>
                ) : (
                    <div className="path-timeline" role="list">
                        {/* Vertical connector line */}
                        <div className="path-tl-line" aria-hidden="true" />

                        {sorted.map((lesson, i) => {
                            const isActive = lesson.status === "in_progress" || lesson.status === "available";
                            const isLocked = lesson.status === "locked";
                            const chipKind = lesson.kind ?? "practice";

                            return (
                                <div
                                    key={lesson.lessonId}
                                    className="path-tl-item"
                                    role="listitem"
                                    ref={lesson.lessonId === fabLesson?.lessonId ? activeItemRef : undefined}
                                >
                                    {/* Node column */}
                                    <div className="path-tl-node-col">
                                        <div className={lessonNodeClass(lesson.status)} aria-label={`Урок ${i + 1}: ${lessonStatusLabel(lesson.status)}`}>
                                            <TimelineNodeLabel lesson={lesson} index={i} />
                                        </div>
                                    </div>

                                    {/* Card */}
                                    <div className={"path-tl-card" + (lesson.status === "in_progress" ? " active" : "")}>
                                        <div className="path-tl-card-top">
                                            <span className="path-tl-eyebrow">УРОК {i + 1}</span>
                                            <span className={lessonStatusClass(lesson.status)}>
                                                {lessonStatusLabel(lesson.status)}
                                            </span>
                                            {isActive && !isLocked && (
                                                <span className="path-tl-action">
                                                    <Link href={`/session/${lesson.lessonId}`}>
                                                        <button className="btn btn-primary path-tl-btn">
                                                            {lessonActionLabel(lesson)} →
                                                        </button>
                                                    </Link>
                                                </span>
                                            )}
                                            {lesson.status === "completed" && (
                                                <span className="path-tl-action">
                                                    <Link href={`/session/${lesson.lessonId}`}>
                                                        <button className="btn btn-ghost path-tl-btn">
                                                            Повторить
                                                        </button>
                                                    </Link>
                                                </span>
                                            )}
                                        </div>

                                        <p className="path-tl-title">{lesson.title}</p>

                                        {/* Task-type chips */}
                                        <div className="path-tl-chips">
                                            <span
                                                className="path-tl-chip"
                                                style={chipStyle(chipKind)}
                                            >
                                                {chipKind === "theory" ? "Теория" : "Практика"}
                                            </span>
                                            {lesson.status === "completed" && lesson.bestScore > 0 && (
                                                <span className="path-tl-chip path-tl-chip--score">
                                                    Результат {lesson.bestScore}%
                                                </span>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
                </>
                )}
            </div>

            {/* Floating action bar — shown while the active lesson card is off-screen */}
            {fabLesson && isFabVisible && (
                <div className="path-fab" role="complementary" aria-label="Быстрый старт">
                    <div className="path-fab-text">
                        <span className="path-fab-eyebrow">Начать следующий урок</span>
                        <span className="path-fab-lesson">{fabLesson.title}</span>
                    </div>
                    <Link href={`/session/${fabLesson.lessonId}`}>
                        <button className="path-fab-btn">
                            Начать →
                        </button>
                    </Link>
                </div>
            )}
        </div>
    );
}

// ─── Page root ───────────────────────────────────────────────────────────────
/**
 * Q-6 (`docs/NIGHT_AUDIT_QUESTIONS.md`). Onboarding's `PUT /skills/enrolled` is best-effort, so a
 * failure there lets the user through to here with only the core skill enrolled instead of the
 * skills they picked. This is the one line that says so, instead of leaving them to wonder why the
 * tree looks nothing like their choice. It renders only after the failure actually happened, and
 * disappears for good as soon as any successful enrollment makes it untrue.
 */
function UnsavedSkillSelectionBanner() {
    const { isSkillSelectionUnsaved, hydrateFromStorage, clearSkillSelectionUnsaved } =
        useOnboardingSkillSelectionStore();

    // Read localStorage after mount, never during render: this value decides whether the banner
    // exists at all, so reading it while rendering would make the server's HTML disagree with the
    // client's first pass.
    useEffect(() => {
        hydrateFromStorage();
    }, [hydrateFromStorage]);

    if (!isSkillSelectionUnsaved) return null;

    return (
        <div className="path-notice" role="status">
            <Icon name="warning" size="sm" />
            <span className="path-notice-text">
                Не удалось сохранить выбор навыков из онбординга — сейчас открыт только базовый
                навык.{" "}
                <Link href="/profile" className="path-notice-link">
                    Выбери навыки в профиле
                </Link>
                .
            </span>
            <button
                type="button"
                className="path-notice-dismiss"
                onClick={clearSkillSelectionUnsaved}
                aria-label="Скрыть сообщение"
            >
                <Icon name="close" size="sm" />
            </button>
        </div>
    );
}

export default function SkillTreePage() {
    const { data: skillTreeData, isLoading, isLoadingError, refetch } = useSkillTree();
    const { data: allSkillsData } = useSkills();
    const { stages } = useSkillStages();
    const { selectedSkill } = useSelectedSkillStore();

    if (isLoading) {
        return (
            <div style={{ display: "flex", alignItems: "center", justifyContent: "center", minHeight: "100vh" }}>
                <Spinner />
            </div>
        );
    }

    // R-6: isLoadingError, not bare isError — a failed background refetch of the whole tree
    // must not replace an already-rendered page with the full-screen error state.
    if (isLoadingError || !skillTreeData) {
        return (
            <div style={{ display: "flex", alignItems: "center", justifyContent: "center", minHeight: "100vh" }}>
                <ErrorState
                    title="Не удалось загрузить дерево навыков"
                    onRetry={() => refetch()}
                />
            </div>
        );
    }

    const allSkills = allSkillsData ?? skillTreeData.skillNodes ?? [];

    const selectedSkillNode = allSkills.find((skill) => skill.slug === selectedSkill?.slug);
    const stageLabel = selectedSkillNode?.stage ? getStageMeta(selectedSkillNode.stage, stages).label : undefined;

    return (
        // Phase 40.23. The assignment strip renders nothing when there is none, so a manager with
        // no assignments lands on exactly the screen they landed on before — the roadmap is
        // explicit that the tree must not be replaced by an empty assignment screen.
        <div className="path-shell">
            <UnsavedSkillSelectionBanner />
            <ActiveAssignmentCard />

            <div className="path-grid">
            {/* MOBILE: sticky skill picker + bottom sheet (hidden on desktop) */}
            <PathMobilePicker activeStageLabel={stageLabel} />

            <PathLeftColumn />

            {/* CENTER: skill detail + timeline */}
            {selectedSkill ? (
                <PathCenterColumn
                    skillSlug={selectedSkill.slug}
                    skillTitle={selectedSkill.title}
                    stageLabel={stageLabel ?? ""}
                    allSkills={allSkills}
                />
            ) : (
                <div className="path-center" style={{ alignItems: "center", justifyContent: "center" }}>
                    <div style={{ textAlign: "center", color: "var(--ink-4)", padding: 40 }}>
                        <div style={{ fontSize: 40, marginBottom: 12 }}>🧭</div>
                        <p style={{ fontSize: 15, fontWeight: 700, color: "var(--ink-2)", marginBottom: 6 }}>
                            Выбери навык
                        </p>
                        <p style={{ fontSize: 13, color: "var(--ink-4)", maxWidth: 240 }}>
                            Нажми на навык слева, чтобы увидеть уроки
                        </p>
                    </div>
                </div>
            )}

            </div>
        </div>
    );
}
