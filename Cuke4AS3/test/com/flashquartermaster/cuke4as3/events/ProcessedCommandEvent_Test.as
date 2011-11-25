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
package com.flashquartermaster.cuke4as3.events
{
    import flash.events.Event;
    import flash.events.EventPhase;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.core.allOf;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.notNullValue;

    public class ProcessedCommandEvent_Test
    {
        private var _sut:ProcessedCommandEvent;

        [Before]
        public function setUp():void
        {
            _sut = new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS, [] );
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }

        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }

        [Test]
        public function should_construct():void
        {
            assertThat( _sut, notNullValue() );
            assertThat( _sut, instanceOf( ProcessedCommandEvent ) );
            assertThat( _sut, instanceOf( Event ) );
            assertThat( _sut.type, equalTo( ProcessedCommandEvent.SUCCESS ) );
            assertThat( _sut.result, arrayWithSize( 0 ) );
            assertThat( _sut.bubbles, isFalse() );
            assertThat( _sut.cancelable, isFalse() );
            assertThat( _sut.eventPhase, EventPhase.AT_TARGET );
        }

        [Test]
        public function should_clone():void
        {
            var clone:ProcessedCommandEvent = ( _sut.clone() as ProcessedCommandEvent );

            assertThat( clone.type, equalTo( _sut.type ) );
            assertThat( clone.result, equalTo( _sut.result ) );
            assertThat( clone.bubbles, equalTo( _sut.bubbles ) );
            assertThat( clone.cancelable, equalTo( _sut.cancelable ) );
            assertThat( clone.eventPhase, allOf( equalTo( _sut.eventPhase ), equalTo( EventPhase.AT_TARGET ) ) );
        }

        [Test]
        public function should_get_result():void
        {
            var result:Array = _sut.result;

            assertThat( result, arrayWithSize( 0 ) );
        }

        [Test]
        public function should_set_result():void
        {
            var expectedResult:Array = ["hello"];
            _sut.result = expectedResult;

            assertThat( _sut.result, equalTo(expectedResult));
        }
    }
}
