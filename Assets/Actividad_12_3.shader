Shader "TC3005C/Pez"
{
    Properties // parámetros recibidos desde Unity
    {
        _ColorChido("Color de la geometría", Color) = (1, 1, 1, 1)
        _ValorChido("valor flotante ejemplo", Float) = 3
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

            // igual que en GLSL - usamos uniforms
            uniform float4 _ColorChido;
            uniform float _ValorChido;

            // declarar las funciones para ambos shaders
            // 1 cosa distinta de sintaxis 
            // 2 "tipos" por variable / funcion
            // 1 es el tipo regular
            // otro es el semantic
            float4 vert(float4 vertexPos : POSITION) : SV_POSITION
            {
                // AQUÍ HAY QUE RECORDAR LA MATRIZ MVP
                // M - Model 
                // V - View 
                // P - Projection 
                // Unity ya tiene un método de conveniencia
                // UnityObjectToClipPos - qué hace?
                // float4 desplazado = float4(vertexPos.x + _ValorChido, vertexPos.y, vertexPos.z, vertexPos.w);
                float4 resultado = UnityObjectToClipPos(vertexPos);
                return float4(resultado.x, resultado.y+ cos(_Time.g + resultado.z), resultado.z, resultado.w);
            }

            float4 frag() : COLOR
            {
                // cuando hablemos de colores aquí recuerden
                // rgba - el a puede ser ignorado (depende cómo esté siendo utilizado el shader)
                // los valores van de 0 a 1
                // return float4(0.0, 1.0, 0.0, 1.0);
                return _ColorChido;
            }

            ENDCG
        }
    }
}
