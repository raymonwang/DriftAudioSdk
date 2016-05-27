package com.lw.RecordImage;

import android.content.Context;
import android.content.res.Resources.NotFoundException;

public class ErrorCode {
	public final static int SUCCESS = 1000;
	public final static int E_NOSDCARD = 1001;
	public final static int E_STATE_RECODING = 1002;
	public final static int E_UNKOWN = 1003;

	public static String getErrorInfo(Context vContext, int vType) throws NotFoundException {
		switch (vType) {
		case SUCCESS:
			return "success";
		case E_NOSDCARD:
			return "E_NOSDCARD";
		case E_STATE_RECODING:
			return "E_STATE_RECODING";
		case E_UNKOWN:
		default:
			return "E_UNKOWN";

		}
	}
}
