package ru.rbt.sqlmodule;

import java.util.HashMap;
import java.util.Map;

import static java.util.Optional.ofNullable;

/**
 * Created by er21006 on 19.05.2017.
 */
public class TemplatesList {

    private Map<Template, String> map = new HashMap<>();

    public TemplatesList addTemplate(Template template, String templateFile) {
        if (map.containsKey(template)) throw new IllegalArgumentException(template.name() + " is already defined");

        map.put(template, templateFile);
        return this;
    }

    public String getTemplateFilename(Template template) {
        return ofNullable(map.get(template)).orElseThrow(() -> new IllegalArgumentException(template.name() + " is absent"));
    }
}
