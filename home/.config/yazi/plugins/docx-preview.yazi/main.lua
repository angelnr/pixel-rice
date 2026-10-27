--- @since 26.9.1
-- Vista previa de .docx con docx2txt (sin LibreOffice).
local M = {}

local function file_path(file)
	return tostring(file.path or file.cache or file.url.path or file.url)
end

function M:peek(job)
	local path = file_path(job.file)
	local output, err = Command("docx2txt"):arg({ path, "-" }):output()

	if err then
		ya.preview_widget(
			job,
			ui.Text({
				ui.Line({ ui.Span("DOCX PREVIEW ERROR"):style(ui.Style():fg("red"):bold()) }),
				ui.Line({ ui.Span("docx2txt: " .. tostring(err)):style(ui.Style():fg("yellow")) }),
				ui.Line({ ui.Span(path):style(ui.Style():fg("blue")) }),
			}):area(job.area):wrap(ui.Wrap.YES)
		)
		return
	end

	if not output or not output.status.success then
		local msg = output and (output.stderr ~= "" and output.stderr or output.stdout) or "sin salida"
		ya.preview_widget(
			job,
			ui.Text({
				ui.Line({ ui.Span("DOCX PREVIEW ERROR"):style(ui.Style():fg("red"):bold()) }),
				ui.Line({ ui.Span(msg):style(ui.Style():fg("yellow")) }),
			}):area(job.area):wrap(ui.Wrap.YES)
		)
		return
	end

	local lines = {}
	for line in (output.stdout or ""):gmatch("[^\r\n]+") do
		table.insert(lines, ui.Line({ ui.Span(line) }))
	end
	if #lines == 0 then
		lines = { ui.Line({ ui.Span("(documento vacío)") }) }
	end

	local skip = job.skip or 0
	local page = {}
	for i = skip + 1, math.min(#lines, skip + job.area.h) do
		table.insert(page, lines[i])
	end
	ya.preview_widget(job, ui.Text(page):area(job.area):wrap(ui.Wrap.YES))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", {
			math.max(0, cx.active.preview.skip + job.units),
			only_if = job.file.url,
		})
	end
end

return M
