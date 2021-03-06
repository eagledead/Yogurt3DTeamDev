package com.yogurt3d.presets.effects
{
	import com.yogurt3d.core.render.post.PostProcessingEffectBase;
	
	import flash.display3D.Context3DProgramType;
	
	public class EffectNoise extends PostProcessingEffectBase
	{
		
		private var m_filter:FilterNoise;
		public function EffectNoise(_amount:Number= 0.0)
		{
			super();
			shader.push( m_filter = new FilterNoise(_amount) );
		}
		
		public function get amount():Number
		{
			return m_filter.amount;
		}
		
		public function set amount(value:Number):void
		{
			m_filter.amount = value;
		}

		public override function render():void{
			trace("\t[EffectNoise][render] start");
			
			super.render();
			
			trace("\t[EffectNoise][render] end");
			
		}
	}
}
import com.adobe.utils.AGALMiniAssembler;
import com.yogurt3d.core.lights.ELightType;
import com.yogurt3d.core.material.shaders.Shader;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.core.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.utils.ByteArray;

internal class FilterNoise extends Shader
{
	
	private var m_amount:Number;
	public function FilterNoise(_amount:Number= 0.0)
	{
		super();
		m_amount = _amount;
	}
	
	public function get amount():Number
	{
		return m_amount;
	}
	
	public function set amount(value:Number):void
	{
		m_amount = value;
	}
	
	public override function setShaderParameters():void{
		device.setTextureAt( 0, PostProcessingEffectBase.sampler);
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_amount, 0.5, 12.9898,78.233]));
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([43758.5453, 0.0, 0.0, 0.0]));
	}
	
	public override function clean():void{
		device.setTextureAt( 0, null);
	}
	
	public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray
	{
		return ShaderUtils.vertexAssambler.assemble( AGALMiniAssembler.VERTEX, 
			"mov op va0\n"+
			"mov v0 va1"
		);
	}
	
	public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			
			[
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				
				"mul ft2.x v0.x fc0.z",
				"mul ft2.y v0.y fc0.w",
				"add ft1.x ft2.x ft2.y",
				
				"sin ft1.x ft1.x",
				"mul ft1.x ft1.x fc1.x",
				"frc ft1.x ft1.x",
				
				"sub ft1.x ft1.x fc0.y",
				"mul ft1.x ft1.x fc0.x",//float diff = (rand(texCoord) - 0.5) * amount;\
				
				"add ft0.x ft0.x ft1.x",
				"add ft0.y ft0.y ft1.x",
				"add ft0.z ft0.z ft1.x",
				
				"mov oc ft0"
				
				
			].join("\n")
			
		);
	}
}