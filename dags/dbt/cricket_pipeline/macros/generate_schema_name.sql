{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    
    {# If no custom schema is defined, use the default target schema #}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    
    {# If a custom schema is defined, use ONLY that name (stripping the target prefix) #}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}