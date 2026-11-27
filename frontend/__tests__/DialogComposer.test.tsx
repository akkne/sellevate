import { describe, it, expect, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { ChatInput } from "@/features/dialog/components/chat-input";

describe("training chat composer", () => {
    it("keeps line breaks and restores the entire draft when sending fails", async () => {
        const user = userEvent.setup();
        const onSend = vi.fn().mockResolvedValue(false);
        render(<ChatInput disabled={false} onSend={onSend} />);
        const field = screen.getByRole("textbox");
        await user.type(field, "Добрый день!{Shift>}{Enter}{/Shift}Удобно говорить?");
        expect(onSend).not.toHaveBeenCalled();
        await user.keyboard("{Enter}");
        const expected = "Добрый день!\nУдобно говорить?";
        expect(onSend).toHaveBeenCalledExactlyOnceWith(expected);
        await waitFor(() => expect(field).toHaveValue(expected));
    });

    it("ignores Enter while the input method is composing", () => {
        const onSend = vi.fn();
        render(<ChatInput disabled={false} onSend={onSend} />);
        const field = screen.getByRole("textbox");
        fireEvent.change(field, { target: { value: "你好" } });
        fireEvent.keyDown(field, { key: "Enter", isComposing: true });
        expect(onSend).not.toHaveBeenCalled();
    });
});
