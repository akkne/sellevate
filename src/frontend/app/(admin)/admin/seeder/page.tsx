"use client";

import { useRef, useState } from "react";
import { useImportSkills, type SkillsImportResult } from "@/lib/hooks/useAdmin";

const CSV_TEMPLATE = [
    "slug,title,icon_name,sort_order,sales_types",
    "cold-calling,Cold Calling,phone,1,b2b_saas|b2c",
    "objection-handling,Objection Handling,shield,2,b2b_saas|retail|b2c",
].join("\n");

const JSON_TEMPLATE = JSON.stringify(
    [
        {
            slug: "cold-calling",
            title: "Cold Calling",
            iconName: "phone",
            sortOrder: 1,
            salesTypes: ["b2b_saas", "b2c"],
        },
        {
            slug: "objection-handling",
            title: "Objection Handling",
            iconName: "shield",
            sortOrder: 2,
            salesTypes: ["b2b_saas", "retail", "b2c"],
        },
    ],
    null,
    2
);

function downloadTemplate(format: "csv" | "json") {
    const content = format === "csv" ? CSV_TEMPLATE : JSON_TEMPLATE;
    const mimeType = format === "csv" ? "text/csv;charset=utf-8;" : "application/json";
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `skills_template.${format}`;
    a.click();
    URL.revokeObjectURL(url);
}

function StatBox({ label, value, accent }: { label: string; value: number; accent?: boolean }) {
    return (
        <div
            className={`rounded-md border px-4 py-3 text-center ${
                accent && value > 0 ? "border-green-200 bg-green-50" : "border-gray-200 bg-white"
            }`}
        >
            <div
                className={`text-2xl font-semibold ${
                    accent && value > 0 ? "text-green-700" : "text-gray-800"
                }`}
            >
                {value}
            </div>
            <div className="text-xs text-gray-500 mt-0.5">{label}</div>
        </div>
    );
}

export default function SeederPage() {
    const fileInputRef = useRef<HTMLInputElement>(null);
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [result, setResult] = useState<SkillsImportResult | null>(null);
    const importSkills = useImportSkills();

    function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
        const f = e.target.files?.[0] ?? null;
        setSelectedFile(f);
        setResult(null);
    }

    async function handleImport() {
        if (!selectedFile) return;
        const data = await importSkills.mutateAsync(selectedFile);
        setResult(data);
        setSelectedFile(null);
        if (fileInputRef.current) fileInputRef.current.value = "";
    }

    return (
        <div className="max-w-2xl">
            <h1 className="text-xl font-semibold text-gray-900 mb-1">Skills Seeder</h1>
            <p className="text-sm text-gray-500 mb-6">
                Bulk-import skills from a CSV or JSON file. Existing skills are updated by slug;
                new ones are created.
            </p>

            {/* Upload card */}
            <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
                <h2 className="text-sm font-medium text-gray-700 mb-4">Upload file</h2>

                <div
                    className="border-2 border-dashed border-gray-300 rounded-md px-6 py-8 text-center cursor-pointer hover:border-gray-400 transition-colors"
                    onClick={() => fileInputRef.current?.click()}
                >
                    <p className="text-sm text-gray-500">
                        {selectedFile ? (
                            <span className="text-gray-800 font-medium">{selectedFile.name}</span>
                        ) : (
                            <>
                                Click to select a{" "}
                                <span className="font-medium">.csv</span> or{" "}
                                <span className="font-medium">.json</span> file
                            </>
                        )}
                    </p>
                    {selectedFile && (
                        <p className="text-xs text-gray-400 mt-1">
                            {(selectedFile.size / 1024).toFixed(1)} KB
                        </p>
                    )}
                </div>
                <input
                    ref={fileInputRef}
                    type="file"
                    accept=".csv,.json"
                    className="hidden"
                    onChange={handleFileChange}
                />

                <div className="mt-4 flex items-center gap-3 flex-wrap">
                    <button
                        onClick={handleImport}
                        disabled={!selectedFile || importSkills.isPending}
                        className="px-4 py-2 text-sm bg-gray-900 text-white rounded-md hover:bg-gray-700 disabled:opacity-40 transition-colors"
                    >
                        {importSkills.isPending ? "Importing…" : "Import"}
                    </button>
                    <button
                        onClick={() => downloadTemplate("csv")}
                        className="px-4 py-2 text-sm border border-gray-300 rounded-md text-gray-600 hover:bg-gray-50 transition-colors"
                    >
                        Download CSV template
                    </button>
                    <button
                        onClick={() => downloadTemplate("json")}
                        className="px-4 py-2 text-sm border border-gray-300 rounded-md text-gray-600 hover:bg-gray-50 transition-colors"
                    >
                        Download JSON template
                    </button>
                </div>

                {importSkills.isError && (
                    <p className="mt-3 text-xs text-red-500">
                        {(importSkills.error as Error).message}
                    </p>
                )}
            </div>

            {/* Result */}
            {result && (
                <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
                    <h2 className="text-sm font-medium text-gray-700 mb-4">Import result</h2>
                    <div className="grid grid-cols-2 gap-3 mb-4">
                        <StatBox label="Skills created" value={result.skillsCreated} accent />
                        <StatBox label="Skills updated" value={result.skillsUpdated} />
                    </div>
                    {result.errors.length > 0 ? (
                        <div className="mt-2">
                            <p className="text-xs font-medium text-red-600 mb-1">
                                {result.errors.length} error{result.errors.length > 1 ? "s" : ""}:
                            </p>
                            <ul className="space-y-0.5">
                                {result.errors.map((e, i) => (
                                    <li key={i} className="text-xs text-red-500 font-mono">
                                        {e}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    ) : (
                        <p className="text-xs text-green-600">Import completed without errors.</p>
                    )}
                </div>
            )}

            {/* Format reference */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h2 className="text-sm font-medium text-gray-700 mb-3">File format</h2>

                <p className="text-xs text-gray-500 font-medium mb-1">CSV columns</p>
                <table className="w-full text-xs border-collapse mb-5">
                    <thead>
                        <tr className="border-b border-gray-200">
                            <th className="text-left py-1.5 px-2 text-gray-500 font-medium">Column</th>
                            <th className="text-left py-1.5 px-2 text-gray-500 font-medium">Type</th>
                            <th className="text-left py-1.5 px-2 text-gray-500 font-medium">Notes</th>
                        </tr>
                    </thead>
                    <tbody className="text-gray-700">
                        {[
                            ["slug", "string", "Unique identifier — upsert key"],
                            ["title", "string", "Display title"],
                            ["icon_name", "string", "Icon name (e.g. phone, handshake)"],
                            ["sort_order", "integer", "Display order in skill tree"],
                            ["sales_types", "string", "Pipe-separated: b2b_saas|retail|b2c"],
                        ].map(([col, type, notes]) => (
                            <tr key={col} className="border-b border-gray-100">
                                <td className="py-1.5 px-2 font-mono text-gray-800">{col}</td>
                                <td className="py-1.5 px-2 text-gray-500">{type}</td>
                                <td className="py-1.5 px-2 text-gray-500">{notes}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>

                <p className="text-xs text-gray-500 font-medium mb-1">JSON format</p>
                <pre className="text-xs bg-gray-50 border border-gray-200 rounded p-3 overflow-x-auto text-gray-700">
{`[
  {
    "slug": "cold-calling",
    "title": "Cold Calling",
    "iconName": "phone",
    "sortOrder": 1,
    "salesTypes": ["b2b_saas", "b2c"]
  }
]`}
                </pre>
            </div>
        </div>
    );
}
