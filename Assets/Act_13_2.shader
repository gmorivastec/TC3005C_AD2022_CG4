Shader "TC3005C/Blanco y Negro"
{
    Properties // parámetros recibidos desde Unity
    {
        _MaterialAmbiental("Color Ambiental", Color) = (1, 1, 1, 1)
        _MaterialDifuso("Color Difuso", Color) = (1, 1, 1, 1)
        _AtenuacionAmbiental("Atenuacion Ambiental", float) = 0.2
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

            // NUEVO - definicion de structs para manejo de datos de retorno / parámetros
            struct vInput {
                float4 vertexPos : POSITION;
                float3 normal : NORMAL;
            };

            struct vOutput {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
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

                float4 especular = float4(0, 0, 0, 1);

                float4 resultado = ambiental + difuso + especular;

                // sacar gris
                float gris = (resultado.r + resultado.g + resultado.b)/3;

                if(gris < 0.4){
                    return 0;
                } else {
                    return 1;
                }
            }

            ENDCG
        }
    }
}
