# Cocos2d-x-3.2 Lua

## Overview
### 1.lua file placement
### 2.use pak

---

#### lua file placement
lua file edit in lua/, then when project luanch, will copy to src/ automatically.

#### use pak
set marco in project, like in ios, is set in Build Settings/Preprocessing/Preprocessor Macros/, set KT_USE_PAK equals true or false.
In Project, make a res_pak folder, put the resource in it, run doomtool, can see help in make_pak.sh(cannot use directly in here), then output a res_pak.pak.Go back to project, add the reference of res_pak.pak to it.