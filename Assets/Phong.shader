Shader "TC3005C/Phong"
{
    Properties // parámetros recibidos desde Unity
    {
        _MaterialAmbiental("Color Ambiental", Color) = (1, 1, 1, 1)
        _MaterialDifuso("Color Difuso", Color) = (1, 1, 1, 1)
        _MaterialEspecular("Color Especular", Color) = (1, 1, 1, 1)
        _Brillo("Coeficiente de brillo", float) = 100
        _AtenuacionAmbiental("Atenuacion Ambiental", float) = 0.2
        _Textura("textura del mono", 2D) = "white" {}
    }
    SubShader // en unity un shader contiene varios posibles subshaders, unity decide cuál utilizar
    {
        Pass // se pueden hacer varios pases como si fueran manos de pintura 
        {
            // aquí es donde va la lógica
            // embebida en algún lenguaje de shading
            // en Unity no importa con lo que lo escribiste, Unity lo recompila para la plataforma objetivo
            CGPROGRAM

            // 1er paso - decirle como se llaman los shaders
            // (aqui van los 2 en un archivo)
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // igual que en GLSL - usamos uniforms
            uniform float4 _MaterialAmbiental;
            uniform float4 _MaterialDifuso;
            uniform float4 _LightColor0;
            uniform float _AtenuacionAmbiental;
            uniform float4 _MaterialEspecular;
            uniform float _Brillo;
            uniform sampler2D _Textura;

            // NUEVO - definicion de structs para manejo de datos de retorno / parámetros
            struct vInput {
                float4 vertexPos : POSITION;
                float3 normal : NORMAL;
                float4 coord : TEXCOORD0;
            };

            struct vOutput {
                float4 vertexLocal : TEXCOORD1;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float4 coord : TEXCOORD0;
            };


            // declarar las funciones para ambos shaders
            // 1 cosa distinta de sintaxis 
            // 2 "tipos" por variable / funcion
            // 1 es el tipo regular
            // otro es el semantic
            vOutput vert(vInput input)
            {
                vOutput resultado;
                resultado.pos = UnityObjectToClipPos(input.vertexPos);
                resultado.normal = input.normal;
                resultado.vertexLocal = input.vertexPos;
                resultado.coord = input.coord;
                return resultado;
            }

            float4 frag(vOutput input) : COLOR
            {

                // KaIa - material * luz
                float4 ambiental = _MaterialAmbiental * _LightColor0 * _AtenuacionAmbiental;

                // difuso - kd(l . n)id
                float4 kd = _MaterialDifuso;
                float4 id = _LightColor0;

                // NOTA IMPORTANTE -
                // ACUÉRDATE QUE LAS OPERACIONES DEBEN SER REALIZADAS EN EL MISMO
                // ESPACIO (LOCAL, GLOBAL, ETC)
                // l - vector que apunta hacia la luz
                // (en espacio del mundo)
                float3 l = normalize(_WorldSpaceLightPos0.xyz);
                
                // la normal de todos los vertices está en espacio local
                float3 n = UnityObjectToWorldNormal(input.normal);

                // producto punto A . B = |A||B|cosθ
                float punto = max(0.0, dot(l, n));
                
                float4 difuso = kd * id * punto;

                // CÁLCULO ESPECULAR 

                // en espacio global
                float3 r = reflect(-l, n);

                // vamos a sacar V 
                // la posicion ya la tenemos PERO en coordenadas homogéneas
                float3 vGlobal = mul(unity_ObjectToWorld, input.vertexLocal).xyz;

                // ya tnemos posición de la cámara
                // _WorldSpaceCameraPos
                float3 v = normalize(_WorldSpaceCameraPos - vGlobal);

                float4 ks = _MaterialEspecular;
                float4 is = _LightColor0;
                float a = _Brillo;

                float4 especular = ks * is * pow(max(dot(r, v), 0), a);
                

                //return ambiental + difuso + especular;

                // TEXTURA 
                // necesitamos 2 fuentes 
                // 1. sampler que es la textura completa
                // 2. la coordenada específica del color que nos concierne aquí
                return tex2D(_Textura, input.coord.xy);
            }

            ENDCG
        }
    }
}
