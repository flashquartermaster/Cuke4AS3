/**
 * Copyright (c) 2011 FlashQuartermaster Ltd
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author Tom Coxen
 * @version
 **/
package com.flashquartermaster.cuke4as3
{
    import flash.filesystem.File;

    public class Config
    {
        public static const OUTPUT_SWF:String = "cuke4as3_steps.swf";
        public static const FEATURES_DIR:String = "features" + File.separator
        public static const STEP_DEFINITIONS_DIR:String = FEATURES_DIR + "step_definitions" + File.separator;
        public static const SUITE_NAME:String = "Cuke4AS3_Suite.as";

        //Error codes
        //Cuke
        public static const CUKE_CANNOT_RUN_ERROR:int = 1000;
        public static const CUKE_NO_WIRE_FILE:int = 1001;

        //Server
        public static const SERVER_CANNOT_RUN_ERROR:int = 2000;
        public static const SERVER_RUN_ERROR:int = 2001;
        //Process
        public static const VALIDATION_ERROR:int = 3000;
        public static const ARGUMENTS_VALIDATION_ERROR:int = 3001;
        public static const SHELL_EXIT_WITH_ERRORS:int = 3010;
        public static const SHELL_EXIT_UNKNOWN_EXIT_CODE:int = 3011;
        public static const FORCED_SHELL_EXIT:int = 3012;

        public static const COMPILER_ERRORS:int = 3020;
    }
}