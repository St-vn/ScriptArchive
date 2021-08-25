local renderStepped = require(game:GetService("ReplicatedStorage").Modules.Auxiliary.FrameRoutines).RenderStepped
--local tweenCount = 0
local toTween = {}

--[[local StepTweens = ]] renderStepped[2] = function(tweenStep)
	for tweenObject, tweenParams in pairs(toTween) do
		tweenParams.TweenAlpha += tweenStep / tweenParams.TweenLength
		local tweenAlpha = math.min(tweenParams.TweenAlpha, 1)

		tweenObject[tweenParams.TweenProperty] = tweenParams.TweenOrigin:Lerp(tweenParams.TweenGoal, math.sin((tweenAlpha * 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679) / 2))

		if tweenAlpha == 1 then
			toTween[tweenObject] = nil
			--[[tweenCount -= 1

			if tweenCount == 0 then
				table.remove(frameRoutines.RenderStepped, 1)
			end]]
		end
	end
end

return function(tweenObject, tweenProperty, tweenGoal, tweenLength)
	toTween[tweenObject] = {
		TweenOrigin = tweenObject[tweenProperty],
		TweenProperty = tweenProperty,
		TweenLength = tweenLength,
		TweenGoal = tweenGoal,
		TweenAlpha = 0
	}
--[[
	tweenCount += 1

	if tweenCount == 1 then
		table.insert(frameRoutines.RenderStepped, 1, StepTweens)
	end]]
end