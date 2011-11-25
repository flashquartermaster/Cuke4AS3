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
package com.flashquartermaster.cuke4as3.vo
{
    import flashx.textLayout.debug.assert;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class MatchInfo_Test
    {
        private var _sut:MatchInfo;

		[Before]
		public function setUp():void
		{
			_sut = new MatchInfo();
		}

		[After]
		public function tearDown():void
		{
			_sut.destroy();
			_sut = null;
		}

        [Test]
        public function should_construct():void
        {
            assertThat( _sut,  notNullValue() );
            assertThat( _sut,  instanceOf( MatchInfo ));
            
            assertThat( _sut.errorMessage, nullValue());
            assertThat( _sut.id, equalTo(-1));
            assertThat( _sut.args, nullValue());
            assertThat( _sut.className, nullValue());
            assertThat( _sut.regExp, nullValue());
            
            assertThat( _sut.isError(), isFalse())
            assertThat( _sut.isMatch(), isFalse())
            assertThat( _sut.isUndefined(), isTrue() );
        }

        [Test]
        public function should_indicate_error():void
        {
            _sut.errorMessage = "An error";
            
            assertThat( _sut.isError(), isTrue() );
            assertThat( _sut.isMatch(), isFalse())
            assertThat( _sut.isUndefined(), isFalse() );
        }

        [Test]
        public function should_indicate_a_match():void
        {
            _sut.id = 4;
            
            assertThat( _sut.isMatch(), isTrue() );
            assertThat( _sut.isError(), isFalse())
            assertThat( _sut.isUndefined(), isFalse() );
        }

        [Test]
        public function should_indicate_undefined_step():void
        {
            assertThat( _sut.isUndefined(), isTrue() );
            assertThat( _sut.isError(), isFalse())
            assertThat( _sut.isMatch(), isFalse())
        }

        [Test]
        public function should_destroy():void
        {
            _sut.errorMessage = "";
            _sut.id = 4;
            _sut.args = [{val:"some value",pos:12}];
            _sut.className = "com.some.ClassType"
            _sut.regExp = "I do \"([^\"]*)\"";
            
            _sut.destroy();
            
            assertThat( _sut.errorMessage, nullValue());
            assertThat( _sut.id, equalTo(-1));
            assertThat( _sut.args, nullValue());
            assertThat( _sut.className, nullValue());
            assertThat( _sut.regExp, nullValue());
            
            assertThat( _sut.isError(), isFalse())
            assertThat( _sut.isMatch(), isFalse())
            assertThat( _sut.isUndefined(), isTrue() );
        }
    }
}
