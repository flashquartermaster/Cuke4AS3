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
package features.support
{
    public class FixtureConfig
    {
        public static var FLEX_HOME:String = "/Users/coxent01/Documents/flex_sdks/flex_sdk_4.5.1";
        public static var MXMLC_EXE:String = FLEX_HOME + "/bin/mxmlc";
        public static var CUCUMBER_EXE:String = "/usr/bin/cucumber";

        public static var EXAMPLES_DIR:String = "/Users/coxent01/Documents/Cuke4AS3/Examples";
        public static var EXAMPLE_CALCULATOR_DIR:String = EXAMPLES_DIR + "/Calculator/src";
        public static var EXAMPLE_CALCULATOR_BAD_COMPILE_DIR:String = EXAMPLES_DIR + "/CalculatorBadCompile/src";
        public static var EXAMPLE_CALCULATOR_BAD_CUCUMBER_DIR:String = EXAMPLES_DIR + "/CalculatorBadCucumber/src";
        public static var EXAMPLE_CALCULATOR_NO_WIRE_DIR:String = EXAMPLES_DIR + "/CalculatorNoWire/src";

//        public static var FLEX_HOME:String = "C:\\flex_sdks\\flex_sdk_4.5.1";
//        public static var MXMLC_EXE:String = FLEX_HOME + "\\bin\\mxmlc.exe";
//        public static var CUCUMBER_EXE:String = "C:\\Ruby192\\bin\\ruby.exe";
        public static var WIN_CUCUMBER_EXE:String = "C:\\Ruby192\\bin\\cucumber";
//
//        public static var EXAMPLES_DIR:String = "C:\\Cuke4AS3\\Examples";
//        public static var EXAMPLE_CALCULATOR_DIR:String = EXAMPLES_DIR + "\\Calculator\\src";
//        public static var EXAMPLE_CALCULATOR_BAD_COMPILE_DIR:String = EXAMPLES_DIR + "\\CalculatorBadCompile\\src";
//        public static var EXAMPLE_CALCULATOR_BAD_CUCUMBER_DIR:String = EXAMPLES_DIR + "\\CalculatorBadCucumber\\src";
//        public static var EXAMPLE_CALCULATOR_NO_WIRE_DIR:String = EXAMPLES_DIR + "\\CalculatorNoWire\\src";
    }
}