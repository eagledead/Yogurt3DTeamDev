package com.yogurt3d.presets.effects
{
	import com.yogurt3d.core.materials.Color;
	import com.yogurt3d.core.render.post.PostProcessingEffectBase;
	
	import flash.display3D.Context3DProgramType;
	
	public class EffectThermalVision extends PostProcessingEffectBase
	{

		private var m_filter:FilterThermalVision;
		public function EffectThermalVision(_color0:Color, _color1:Color, _color2:Color, _threshold:Number = 0.5)
		{
			super();
		
			shader.push( m_filter = new FilterThermalVision(_color0, _color1, _color2, _threshold) );
		}
				
		public function get color0():Color{
			return m_filter.color0;
		}
		
		public function set color0(_value:Color):void{
			m_filter.color0 = _value;
		}
		
		public function get threshold():Number{
			return m_filter.threshold;
		}
		
		public function set threshold(_value:Number):void{
			m_filter.threshold = _value;
		}
		
		public function get color1():Color{
			return m_filter.color1;
		}
		
		public function set color1(_value:Color):void{
			m_filter.color1 = _value;
		}
		
		public function get color2():Color{
			return m_filter.color2;
		}
		
		public function set color2(_value:Color):void{
			m_filter.color2 = _value;
		}
		
		public override function render():void{
			trace("\t[EffectThermalVision][render] start");
			
			super.render();
			
			trace("\t[EffectThermalVision][render] end");
			
		}
	}
}
import com.adobe.utils.AGALMiniAssembler;
import com.yogurt3d.core.lights.ELightType;
import com.yogurt3d.core.material.shaders.Shader;
import com.yogurt3d.core.materials.Color;
import com.yogurt3d.core.render.post.PostProcessingEffectBase;
import com.yogurt3d.core.utils.ShaderUtils;

import flash.display3D.Context3DProgramType;
import flash.utils.ByteArray;

internal class FilterThermalVision extends Shader
{
	private var m_color0:Color;
	private var m_color1:Color;
	private var m_color2:Color;
	private var m_threshold:Number;
	
	public function FilterThermalVision(_color0:Color, _color1:Color, _color2:Color, _threshold:Number = 0.5)
	{
		super();
		
		m_color0 = _color0;
		m_color1 = _color1;
		m_color2 = _color2;
		
		m_threshold = _threshold;
		
	}
	
	public function get color0():Color{
		return m_color0;
	}
	
	public function set color0(_value:Color):void{
		m_color0 = _value;
	}
	
	public function get color1():Color{
		return m_color1;
	}
	
	public function set color1(_value:Color):void{
		m_color1 = _value;
	}
	
	public function get color2():Color{
		return m_color2;
	}
	
	public function set color2(_value:Color):void{
		m_color2 = _value;
	}
	
	public function get threshold():Number{
		return m_threshold;
	}
	
	public function set threshold(_value:Number):void{
		m_threshold = _value;
	}
	
	public override function setShaderParameters():void{
		device.setTextureAt( 0, PostProcessingEffectBase.sampler);
		
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  m_color0.getColorVector());
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  m_color1.getColorVector());
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  m_color2.getColorVector());
		device.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([3.0, m_threshold, 0.005, 1.0]));
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
		
		//			vec3 pixcol = texture2D(sceneTex, uv).rgb;
		//			vec3 colors[3];
		//			colors[0] = vec3(0.,0.,1.);
		//			colors[1] = vec3(1.,1.,0.);
		//			colors[2] = vec3(1.,0.,0.);
		//			float lum = (pixcol.r+pixcol.g+pixcol.b)/3.;
		//			int ix = (lum < threshold)? 0:1;
		//			tc = mix(colors[ix],colors[ix+1],(lum-float(ix)*threshold)/threshold);
		
		return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
			
			[
				
				"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				"add ft1.x ft0.x ft0.y",
				"add ft1.x ft1.x ft0.z",
				"div ft1.x ft1.x fc3.x",//ft1 = lum = (pixcol.r+pixcol.g+pixcol.b)/3.;
				
				"sge ft2.x ft1.x fc3.y", //ft2 = ix = (lum < threshold)? 0:1;
				
				"mul ft3.x ft2.x fc3.y",//float(ix)*threshold
				"sub ft3.x ft1.x ft3.x", //lum-float(ix)*threshold
				"div ft3.x ft3.x fc3.y", //ft3 = (lum-float(ix)*threshold)/threshold
				
				"sub ft2.y fc3.w ft2.x",
				
				"sub ft7.x fc3.w ft3.x",
				ShaderUtils.mix("ft4","ft6","fc0", "fc1", "ft3.x", "ft7.x"),
				ShaderUtils.mix("ft5","ft6","fc1", "fc2", "ft3.x", "ft7.x"),
				
				"mul ft4 ft4 ft2.y",
				"mul ft5 ft5 ft2.x",
				"add ft0 ft4 ft5",
				
				"mov ft0.w fc3.w",//alpha = 1
				"mov oc ft0"
				
			].join("\n")
			
		);
	}
}