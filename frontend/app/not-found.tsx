"use client";

import { useHydrated } from "@/shared/hooks/use-hydrated";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Icon } from "@/shared/components/icon";
import { Button } from "@/shared/components/button";

export default function NotFound() {
    const pathname = usePathname();

    const isMounted = useHydrated();

    if (!isMounted) {
        return <NotFoundLayout>{null}</NotFoundLayout>;
    }

    if (pathname?.startsWith("/admin")) {
        return (
            <NotFoundLayout>
                <h1 className="font-medium text-ink" style={{ fontSize: 20, marginBottom: 8 }}>
                    Page not found
                </h1>
                <p className="text-sm text-ink-3" style={{ maxWidth: 360, marginBottom: 24 }}>
                    This page doesn&apos;t exist or has been moved.
                </p>
                <Link href="/admin">
                    <Button variant="primary">Back to admin</Button>
                </Link>
            </NotFoundLayout>
        );
    }

    if (pathname?.startsWith("/org")) {
        return (
            <NotFoundLayout>
                <h1 className="font-medium text-ink" style={{ fontSize: 20, marginBottom: 8 }}>
                    Страница не найдена
                </h1>
                <p className="text-sm text-ink-3" style={{ maxWidth: 360, marginBottom: 24 }}>
                    Такой страницы не существует или она была перемещена. Вернитесь в панель
                    организации и откройте нужный раздел оттуда.
                </p>
                <Link href="/org">
                    <Button variant="primary">Вернуться в панель</Button>
                </Link>
            </NotFoundLayout>
        );
    }

    return (
        <NotFoundLayout>
            <h1 className="font-medium text-ink" style={{ fontSize: 20, marginBottom: 8 }}>
                Страница не найдена
            </h1>
            <p className="text-sm text-ink-3" style={{ maxWidth: 360, marginBottom: 24 }}>
                Такой страницы не существует или она была перемещена.
            </p>
            <Link href="/tree">
                <Button variant="primary">Вернуться к пути</Button>
            </Link>
        </NotFoundLayout>
    );
}

function NotFoundLayout({ children }: { children: React.ReactNode }) {
    return (
        <div
            className="flex flex-col items-center justify-center text-center"
            style={{ minHeight: "100vh", padding: "24px" }}
        >
            <div
                className="flex items-center justify-center"
                style={{ width: 56, height: 56, borderRadius: 16, background: "var(--surface-2)", marginBottom: 16 }}
            >
                <Icon name="compass" size="lg" />
            </div>
            {children}
        </div>
    );
}
