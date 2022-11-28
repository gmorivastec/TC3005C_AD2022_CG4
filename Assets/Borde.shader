Shader "Custom/Borde"
{
    Properties
    {
        _Anchura("Anchura de borde", float) = 0.03
    }
    SubShader
    {
       Pass {

        // CON STENCIL DEFINIMOS LAS OPERACIONES PARA DETERMINAR
        // QUÉ SE VA A A DIBUJAR Y CUANDO
        Stencil {
            Ref 1
            Comp Always
            Pass Replace
        }

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag

        float4 vert(float4 pos : POSITION) : SV_POSITION {

            return UnityObjectToClipPos(pos);
        }

        float4 frag() : COLOR {
            return float4(0.0, 0.0, 1.0, 1.0);
        }
        ENDCG

       }

       Pass {

        Stencil {
            Ref 1
            Comp NotEqual
            Pass Keep
        }

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag

        uniform float _Anchura;
        
        float4 vert(float4 pos : POSITION, float3 normal : NORMAL) : SV_POSITION {

            return UnityObjectToClipPos(pos + normal * _Anchura);
        }

        float4 frag() : COLOR {
            return float4(0.0, 0.0, 0.0, 1.0);
        }

        ENDCG
       }

    }
    FallBack "Diffuse"
}
