--[[
	@Author: Berezaa & Gavin "Mullets" Rosenthal
	@Desc: Numbers script to calculate prefixes and suffixes
--]]

--// logic
local Numbers = {}
Numbers.Suffixes = {'k','M','B','T','qd','Qn','sx','Sp','O','N','de','Ud','DD','tdD','qdD','QnD','sxD','SpD','OcD','NvD',
	'Vgn','UVg','DVg','TVg','qtV','QnV','SeV','SPG','OVG','NVG','TGN','UTG','DTG','tsTG','qtTG','QnTG','ssTG','SpTG','OcTG',
	'NoTG','QdDR','uQDR','dQDR','tQDR','qdQDR','QnQDR','sxQDR','SpQDR','OQDDr','NQDDr','qQGNT','uQGNT','dQGNT','tQGNT',
	'qdQGNT','QnQGNT','sxQGNT','SpQGNT', 'OQQGNT','NQQGNT','SXGNTL'}

--// functions
function Numbers.formatMoney(input)
	local Negative = input < 0
	input = math.abs(input)

	local Paired = false
	for i,v in pairs(Numbers.Suffixes) do
		if not (input >= 10^(3*i)) then
			input = input / 10^(3*(i-1))
			local isComplex = (string.find(tostring(input),'.') and string.sub(tostring(input),4,4) ~= '.')
			input = string.sub(tostring(input),1,(isComplex and 4) or 3) .. (Numbers.Suffixes[i-1] or '')
			Paired = true
			break;
		end
	end
	if not Paired then
		local Rounded = math.floor(input)
		input = tostring(Rounded)
	end

	if Negative then
		return '-'..input
	end
	return input
end

function Numbers.formatClock(input)
	local seconds = tonumber(input)

	if seconds <= 0 then
		return '0:00';
	else
		local mins = string.format('%01.f', math.floor(seconds / 60));
		local secs = string.format('%02.f', math.floor(seconds - mins * 60));
		return mins.. ':' ..secs
	end
end

function Numbers.formatDate(input)
	local days = math.floor(input/86400)
	local hours = math.floor(math.fmod(input, 86400)/3600)
	local minutes = math.floor(math.fmod(input,3600)/60)
	local seconds = math.floor(math.fmod(input,60))
	return string.format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

return Numbers