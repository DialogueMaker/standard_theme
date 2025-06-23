--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local IJW = require(ReplicatedStorage.StandardTheme.roblox_packages.ijw);
local TestRunner = IJW.TestRunner;

local tests = TestRunner:findTestsFromAncestors({ReplicatedStorage.StandardTheme}, ".test");
local results = TestRunner:runTests(tests);

TestRunner:displayResults(results);

return results;