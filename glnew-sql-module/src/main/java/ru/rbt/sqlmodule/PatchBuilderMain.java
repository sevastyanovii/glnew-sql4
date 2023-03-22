package ru.rbt.sqlmodule;

import java.io.*;

/**
 * Created by Ivan Sevastyanov
 */
public class PatchBuilderMain {

    public static void main(String[] args) throws IOException {
        File trunkFile = new File(args[0]);
        File patchFile = new File(args[1]);
        patchFile.delete();
        patchFile.createNewFile();

        try(
                FileInputStream fis = new FileInputStream(trunkFile); InputStreamReader isr = new InputStreamReader(fis, SqlModuleConstants.getInputCharset()); BufferedReader trunkFileBufferedReader = new BufferedReader(isr);
                FileOutputStream fos = new FileOutputStream(patchFile); OutputStreamWriter osr = new OutputStreamWriter(fos, SqlModuleConstants.getInputCharset()); BufferedWriter patchFileBufferedWriter = new BufferedWriter(osr);
        ) {

            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.write("SET SCHEMA DWH;");
            patchFileBufferedWriter.newLine();
            patchFileBufferedWriter.write("SET PATH QSYS, QSYS2, DWH;");
            patchFileBufferedWriter.newLine();

            for (String scriptRelitivePath = trunkFileBufferedReader.readLine(); null != scriptRelitivePath;
                 scriptRelitivePath = trunkFileBufferedReader.readLine()) {
                if (!isEmpty(scriptRelitivePath)) {
                    patchFileBufferedWriter.newLine();
                    patchFileBufferedWriter.write("-- ================= Patch script: " + scriptRelitivePath + "   =================");
                    patchFileBufferedWriter.newLine();
                    patchFileBufferedWriter.newLine();
                    try (FileInputStream scriptFileInputStream = new FileInputStream(trunkFile.getParentFile() + "/" + scriptRelitivePath);
                         InputStreamReader scriptFileInputStreamReader = new InputStreamReader(scriptFileInputStream, SqlModuleConstants.getInputCharset());
                         BufferedReader scriptFileBufferedReader = new BufferedReader(scriptFileInputStreamReader)
                    ) {

                        char[] buffer = new char[1024];
                        int cnt;
                        while ((cnt = scriptFileBufferedReader.read(buffer)) > 0) {
                            patchFileBufferedWriter.write(buffer, 0, cnt);
                        }
                        patchFileBufferedWriter.flush();
                    }
                }
            }
        }

    }

    private static boolean isEmpty(String target) {
        return null == target || target.trim().isEmpty();
    }
}
