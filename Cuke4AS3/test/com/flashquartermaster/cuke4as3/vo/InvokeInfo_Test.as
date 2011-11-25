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
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class InvokeInfo_Test
    {
        private var _sut:InvokeInfo;

		[Before]
		public function setUp():void
		{
			_sut = new InvokeInfo();
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
            assertThat( _sut, notNullValue() );
            assertThat( _sut, instanceOf( InvokeInfo ));

            assertThat( _sut.errorMessage, nullValue());
            assertThat( _sut.errorName, nullValue());
            assertThat( _sut.errorTrace, nullValue());

            assertThat( _sut.pendingMessage, nullValue());

            assertThat( _sut.isError(), isFalse())
            assertThat( _sut.isPending(), isFalse())
            assertThat( _sut.isSuccess(), isTrue() );
        }

        [Test]
        public function should_indicate_error():void
        {
            _sut.errorMessage = "An error";

            assertThat( _sut.isError(), isTrue() );
            assertThat( _sut.isPending(), isFalse() );
            assertThat( _sut.isSuccess(), isFalse() );
        }

        [Test]
        public function should_indicate_pending():void
        {
            _sut.pendingMessage = "some message";

            assertThat( _sut.isPending(), isTrue() );
            assertThat( _sut.isError(), isFalse() );
            assertThat( _sut.isSuccess(), isFalse() );
        }

        [Test]
        public function should_indicate_success():void
        {
            assertThat( _sut.isSuccess(), isTrue() );
            assertThat( _sut.isPending(), isFalse() );
            assertThat( _sut.isError(), isFalse() );
        }

        [Test]
        public function should_destroy():void
        {
            _sut.errorMessage = "";
            _sut.errorName = "";
            _sut.errorTrace = "";

            _sut.pendingMessage = "";

            _sut.destroy();

            assertThat( _sut.errorMessage, nullValue());
            assertThat( _sut.errorName, nullValue());
            assertThat( _sut.errorTrace, nullValue());

            assertThat( _sut.pendingMessage, nullValue());

            assertThat( _sut.isError(), isFalse())
            assertThat( _sut.isPending(), isFalse())
            assertThat( _sut.isSuccess(), isTrue() );
        }
    }
}
