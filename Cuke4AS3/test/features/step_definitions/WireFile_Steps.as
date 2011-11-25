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
package features.step_definitions
{
    import com.flashquartermaster.cuke4as3.filesystem.WireFileParser;
    import com.flashquartermaster.cuke4as3.utilities.Pending;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;
    import com.flashquartermaster.cuke4as3.utilities.Table;
    import com.flashquartermaster.cuke4as3.vo.ServerInfo;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;

    import support.FileHelper;

    public class WireFile_Steps extends StepsBase
    {
        private var _sut:WireFileParser;

        private var _fileHelper:FileHelper;
        private var _serverInfo:ServerInfo;

        public function WireFile_Steps()
        {
        }

        [Given(/^I have a wire file containing:$/)]
        public function should_have_wire_file_containing( docString:String ):void
        {
            _fileHelper = new FileHelper();
            _fileHelper.makeValidWireFile( getHost( docString ), getPort( docString ) );
        }

        [When(/^I parse it$/)]
        public function should_parse_it():void
        {
            _sut = new WireFileParser();
            _serverInfo = _sut.getServerInfoFromWireFile( _fileHelper.getValidTmpDirectory() );
        }

        [Then(/^the results are:$/)]
        public function the_results_should_be( array:Array ):void
        {
            var table:Table = new Table( array );

            assertThat( _serverInfo.host, equalTo( table.getRowItemByHeader( "host", 0 ) ) );
            assertThat( _serverInfo.port, equalTo( table.getRowItemByHeader( "port", 0 ) ) );
        }

        [Given(/^the environment setting for PORT is (\d+)$/)]
        public function environment_setting_for_port_should_be( n1:Number ):void
        {
            throw new Pending( "Awaiting implementation" );
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.destroy();
            _sut = null;

            _fileHelper.destroy();
            _fileHelper = null;

            _serverInfo = null;
        }

        //Support

        private function getPort( s:String ):int
        {
            var getPort:RegExp = /port:\s*?(\d+)$/gi;
            var port:Object = getPort.exec( s );

//            Detect <%= ENV['PORT'] || 12345 %> and parse correctly

            return int( port[1] );
        }

        private function getHost( s:String ):String
        {
            var getHost:RegExp = /host:\s*?(\S.*)/gi;
            var host:Object = getHost.exec( s );
            return host[1];
        }
    }
}
