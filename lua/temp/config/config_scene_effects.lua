
--==================================================
--    @Brief:   scene transition effects
--    @Author:  Rios
--    @Date:    2015-10-12
--==================================================

module (...,package.seeall)

local _transitionSceneTypes = 
{
	--淡出
	kTransitionFade = function ( duration, scene )
		return CCTransitionFade:create(duration, scene)
	end,

	--翻页
	kTransitionPageTurn = function (duration, scene )
		return CCTransitionPageTurn:create(duration, scene, false)
	end,

	--扇形 逆时针
	kTransitionProgressRadialCCW = function (duration, scene )
		return CCTransitionProgressRadialCCW:create(duration, scene)
	end,

	--其它，可参考 http://blog.csdn.net/song_hui_xiang/article/details/8721132

}

local SceneEffects = SceneEffects or class("SceneEffects")
SceneEffects.__cname = "SceneEffects"

function SceneEffects:ctor( ... )
	for k,v in pairs(_transitionSceneTypes) do
		self[k]=v
	end
end

-- 全局单例
local scene_effect_instance = nil
function SceneEffects:getInstance( ... )
	if not scene_effect_instance then
        scene_effect_instance = SceneEffects.new()
    end

    SceneEffects.new = function ( ... )
    	error("SceneEffects.new()--->access error!")
    end

    return scene_effect_instance
end

_G["config_scene_effects"] = SceneEffects:getInstance()



--[[------------------------------------------------------------------------------------------------------
	--http://blog.csdn.net/song_hui_xiang/article/details/8721132

    //扇形 逆时针
//    CCTransitionScene* transition = CCTransitionProgressRadialCCW::create(1.5f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //扇形  顺时针
//    CCTransitionScene* transiton = CCTransitionProgressRadialCW::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transiton);
    
    //水平进度条
//    CCTransitionScene* transition = CCTransitionProgressHorizontal::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //垂直进度条
//    CCTransitionScene* transition = CCTransitionProgressVertical::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    
    //由里到外扩展
//    CCTransitionScene* transition = CCTransitionProgressInOut::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
//    CCTransitionScene* transition = CCTransitionProgressOutIn::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
//    //逐渐透明
//    CCTransitionScene* transition = CCTransitionCrossFade::create(4.5f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //翻页
//    CCTransitionScene* transition = CCTransitionPageTurn::create(0.5f, MyScene::createMyScene(),false);
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //跳动
//    CCTransitionScene* transition = CCTransitionJumpZoom::create(2.0f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
//    //部落格过度
//    CCTransitionScene* transition = CCTransitionFadeTR::create(3.5f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
//    CCTransitionScene* transiton = CCTransitionFadeBL::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transiton);
    
    //条形折叠
//    CCTransitionScene* transition = CCTransitionFadeUp::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //随机方格消失 
//    CCTransitionScene* transition = CCTransitionTurnOffTiles::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //分行划分切换
//    CCTransitionScene* transition = CCTransitionSplitRows::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //分列
//    CCTransitionScene* transition = CCTransitionSplitCols::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //颜色过渡
//    CCTransitionScene* transition = CCTransitionFade::create(12.f, MyScene::createMyScene(), ccc3(120, 25, 100));
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //X轴反转切换画面
//    CCTransitionScene* transition = CCTransitionFlipX::create(1.2f, HelloWorld::scene());
//    CCDirector::sharedDirector()->replaceScene(transition);

    //Y轴
//    CCTransitionScene* transtion = CCTransitionFlipY::create(1.2f, HelloWorld::scene());
//    CCDirector::sharedDirector()->replaceScene(transtion);
    
    //反转角的反转切换直动画
//    CCTransitionScene* transition = CCTransitionFlipAngular::create(1.2f, HelloWorld::scene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
//    CCTransitionScene* transition = CCTransitionZoomFlipX::create(1.2f, HelloWorld::scene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //缩放交替
//    CCTransitionScene* transition = CCTransitionShrinkGrow::create(1.2f, MyScene::createMyScene());
//    CCDirector::sharedDirector()->replaceScene(transition);
    
    //旋转绽放
//    CCTransitionScene* transition = CCTransitionRotoZoom::create(1.2f, HelloWorld::scene());
//    CCDirector::sharedDirector()->replaceScene(transition);
--]]------------------------------------------------------------------------------------------------------
