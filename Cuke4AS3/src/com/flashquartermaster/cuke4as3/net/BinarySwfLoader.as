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
package com.flashquartermaster.cuke4as3.net
{
    import com.furusystems.logging.slf4as.global.error;
    import com.furusystems.logging.slf4as.global.info;

    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;

    public class BinarySwfLoader extends EventDispatcher
    {
        private var _swfToLoad:String;

        private var _urlLoader:URLLoader;
        private var _loader:Loader;

        private var _applicationDomain:ApplicationDomain;

        private var _running:Boolean = false;

        public function BinarySwfLoader()
        {
            _running = false;
        }

        public function init():void
        {
            info( "BinarySwfLoader : init" );

            if( _urlLoader == null )
            {
                _urlLoader = new URLLoader();
                addUrlLoaderListeners();
            }

            if( _loader == null )
            {
                _loader = new Loader();
                addLoaderListeners();
            }
        }

        public function load():void
        {
            _running = true;
            _urlLoader.load( new URLRequest( _swfToLoad ) );
        }

        //fires when URLLoader is done

        private function urlLoaderComplete( event:Event ):void
        {
            info( "BinarySwfLoader : urlLoaderComplete :", event );
            removeUrlLoaderListeners();
            //Make a new application domain in order that recompiled versions of the same
            //file do not clash and changes are picked up
            _applicationDomain = new ApplicationDomain( ApplicationDomain.currentDomain );

            var lc:LoaderContext = new LoaderContext( false, _applicationDomain );
            lc.allowCodeImport = true;

            _loader.loadBytes( _urlLoader.data, lc );
        }

        //fires when Loader is done after the URLLoader completes

        private function loaderInitCompleteHandler( event:Event ):void
        {
            removeLoaderListeners();
            _running = false;
            dispatchEvent( new Event( Event.COMPLETE ) );
        }

        private function urlLoaderSecurityError( event:SecurityErrorEvent ):void
        {
            error( "BinarySwfLoader : urlLoaderSecurityError :", event );
            _running = false;
            dispatchErrorEvent( event );
        }

        private function urlLoaderIOError( event:IOErrorEvent ):void
        {
            error( "BinarySwfLoader : urlLoaderIOError :", event );
            _running = false;
            dispatchErrorEvent( event );
        }

        private function loaderIOErrorHandler( event:IOErrorEvent ):void
        {
            error( "BinarySwfLoader : loaderIoErrorHandler :", event );
            _running = false;
            dispatchErrorEvent( event );
        }

        public function stop():void
        {
            if( running )
            {
                _urlLoader.close();
                _loader.close();
                _running = false;
            }
        }

        public function destroy():void
        {
            info("BinarySwfLoader : destroy");
            stop();

            if( _urlLoader != null )
            {
                removeUrlLoaderListeners();
                _urlLoader = null;
            }

            _swfToLoad = null;

            if( _loader != null )
            {
                removeLoaderListeners();

                _loader.unloadAndStop( true );
                _loader = null;
            }

            _applicationDomain = null;
            _running = false;
        }

        private function dispatchErrorEvent( event:ErrorEvent ):void
        {
            dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, event.text, event.errorID ) );
        }

        public function get swfToLoad():String
        {
            return _swfToLoad;
        }

        public function set swfToLoad( value:String ):void
        {
            _swfToLoad = value;
        }

        public function get running():Boolean
        {
            return _running;
        }

        public function get applicationDomain():ApplicationDomain
        {
            return _applicationDomain;
        }

        //Add & remove listeners

        private function addUrlLoaderListeners():void
        {
            _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            _urlLoader.addEventListener( Event.COMPLETE, urlLoaderComplete );
            _urlLoader.addEventListener( IOErrorEvent.IO_ERROR, urlLoaderIOError );
            _urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, urlLoaderSecurityError );
            //
//			_urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, urlLoaderHttpStatus );
//			_urlLoader.addEventListener(Event.OPEN, urlLoaderOpenHandler);
//			_urlLoader.addEventListener(ProgressEvent.PROGRESS, urlLoaderProgressHandler);
        }

        private function removeUrlLoaderListeners():void
        {
            _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            _urlLoader.removeEventListener( Event.COMPLETE, urlLoaderComplete );
            _urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, urlLoaderIOError );
            _urlLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, urlLoaderSecurityError );
            //
//			_urlLoader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, urlLoaderHttpStatus );
//			_urlLoader.removeEventListener(Event.OPEN, urlLoaderOpenHandler);
//			_urlLoader.removeEventListener(ProgressEvent.PROGRESS, urlLoaderProgressHandler);
        }

        private function addLoaderListeners():void
        {
            _loader.contentLoaderInfo.addEventListener( Event.INIT, loaderInitCompleteHandler );
            _loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loaderIOErrorHandler );
            //
//			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
//			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler);
//			_loader.contentLoaderInfo.addEventListener(Event.OPEN, loaderOpenHandler);
//			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
//			_loader.contentLoaderInfo.addEventListener(Event.UNLOAD, loaderUnLoadHandler);
        }

        private function removeLoaderListeners():void
        {
            _loader.contentLoaderInfo.removeEventListener( Event.INIT, loaderInitCompleteHandler );
            _loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, loaderIOErrorHandler );
            //
//			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
//			_loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler);
//			_loader.contentLoaderInfo.removeEventListener(Event.OPEN, loaderOpenHandler);
//			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
//			_loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, loaderUnLoadHandler);
        }

        //Debug
//		protected function urlLoaderProgressHandler(event:Event):void
//		{
//			debug( "BinarySwfLoader : urlLoaderProgressHandler :", event);
//		}
//		
//		protected function urlLoaderOpenHandler(event:Event):void
//		{
//			debug( "BinarySwfLoader : urlLoaderOpenHandler :", event);
//		}
//		
//		protected function urlLoaderHttpStatus(event:HTTPStatusEvent):void
//		{
//			debug( "BinarySwfLoader : urlLoaderHttpStatus :", event);
//		}

//		protected function loaderUnLoadHandler(event:Event):void
//		{
//			debug( "BinarySwfLoader : loaderUnLoadHandler :", event);
//		}
//		
//		protected function loaderProgressHandler(event:ProgressEvent):void
//		{
//			debug( "BinarySwfLoader : loaderProgressHandler :", event);
//		}
//		
//		protected function loaderOpenHandler(event:Event):void
//		{
//			debug( "BinarySwfLoader : loaderOpenHandler :", event);
//		}
//		
//		protected function loaderHttpStatusHandler(event:HTTPStatusEvent):void
//		{
//			debug( "BinarySwfLoader : loaderHttpStatusHandler :", event);
//		}
    }
}