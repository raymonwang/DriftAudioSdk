package com.lw.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

public class InputStreamUtils {
	public static InputStream byte2Input(byte[] buf) {
		return new ByteArrayInputStream(buf);
	}

	public static byte[] input2byte(InputStream inStream) {
		try {
			ByteArrayOutputStream swapStream = new ByteArrayOutputStream();
			byte[] buff = new byte[1024];
			int rc = 0;
			while ((rc = inStream.read(buff, 0, 1024)) > 0) {
				swapStream.write(buff, 0, rc);
			}
			return swapStream.toByteArray();
		} catch (Exception e) {
			// TODO: handle exception
		}
		return null;
	}
}
