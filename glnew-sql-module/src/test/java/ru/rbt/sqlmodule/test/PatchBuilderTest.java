package ru.rbt.sqlmodule.test;

import org.junit.Test;
import ru.rbt.sqlmodule.PatchBuilderMainTrunk;
import ru.rbt.sqlmodule.PatchBuilderMainVersion;

/**
 * Created by Ivan Sevastyanov
 */
public class PatchBuilderTest {

    @Test public void testParser2() throws Exception {
        PatchBuilderMainTrunk.main(new String[]{"C:\\develop\\projects\\BarsGL\\BarsGL_Online_SQL\\barsgl-sql\\trunk.xml"});
    }

    /**
     * формирование патча на основе versions.xml
     * @throws Exception
     */
    @Test public void testParser3() throws Exception {
        PatchBuilderMainVersion.main(new String[]{"C:\\dev\\projects\\barsgl-sql\\versions.xml", "1.5.2"});
    }

}
