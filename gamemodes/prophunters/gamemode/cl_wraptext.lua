

local Builder = {}
Builder.__index = Builder
function Builder:WriteBlock(newLine)
	local block = {}
	block.text = self.curText
	block.color = self.curColor
	block.startX = self.startX
	block.newLine = newLine
	table.insert(self.blocks, block)
	self.curText = ""
	self.startX = self.curWidth
	if newLine then
		self.startX = 0
		self.curWidth = 0
	end
end

function Builder:Run()
	self.blocks = {}
	self.curColor = Color(255, 255, 255)
	self.curWidth = 0
	self.startX = 0
	self.curText = ""

	surface.SetFont(self.font)

	for k, v in pairs(self.textTable) do
		if type(v) == "table" then
			self:WriteBlock(false)
			self.curColor = v
		elseif type(v) == "string" then
			local txt = v
			local firstChunk = true
			for chunk in (txt .. "\n"):gmatch("([^\n]-)\n") do
				if !firstChunk then
					self:WriteBlock(true)
				end
				firstChunk = false
				local spaces, rest = chunk:match("^([%s]*)(.*)$")
				-- print(#spaces, "<" .. rest)

				local sw, sh = surface.GetTextSize(spaces)
				self.curText = self.curText .. spaces
				self.curWidth = self.curWidth + sw

				for word in rest:gmatch("([^%s]+[%s]*)") do
					local w, h = surface.GetTextSize(word)

					// can't we fit the word on the same line
					if w + self.curWidth > self.maxWidth then

						// is the word too long for a single line (then we need to split it)
						if w > self.maxWidth then

							// while our current word cannot fit in the line
							while self.curWidth + w > self.maxWidth do

								// find the number of chracters that can fit
								local chars = 1
								while true do
									local aw, ah = surface.GetTextSize(word:sub(1, chars))
									if chars > #word then
										print('error' .. chars)
										break
									end
									if aw + self.curWidth > self.maxWidth then
										chars = chars - 1
										break
									end
									chars = chars + 1
								end

								// add the partial word to line
								self.curText = self.curText .. word:sub(1, chars)
								self:WriteBlock(true)

								// start a new line with the rest of the characters
								self.curWidth = 0
								self.curText = ""

								word = word:sub(chars + 1)
								w, h = surface.GetTextSize(word)
							end

							self.curWidth = w
							self.curText = word
						else
							// put the word on a new line
							self:WriteBlock(true)

							self.curWidth = w
							self.curText = word
						end
					else
						// add the word to the current line
						self.curText = self.curText .. word
						self.curWidth = self.curWidth + w
					end
				end
				if #chunk == 0 then
					-- self:WriteBlock(true)
				end
			end // end chunk loop
		end
	end
	self:WriteBlock(true)
	local h = 0
	for k, line in pairs(self.blocks) do
		if line.newLine then
			h = h + draw.GetFontHeight(self.font)
		end
	end
	self.height = h
end

function Builder:Paint(bx, by)
	local y = 4
	for k, line in pairs(self.blocks) do
		draw.DrawText(line.text, self.font, bx + line.startX, by + y, line.color or color_white, 0)
		if line.newLine then
			y = y + draw.GetFontHeight(self.font)
		end
	end
end

function WrapText(font, maxWidth, textTable)
	local tab = {}
	tab.font = font
	tab.maxWidth = maxWidth
	tab.textTable = textTable
	tab.blocks = {}
	setmetatable(tab, Builder)
	tab:Run()
	return tab
end