/* Copyright (c) 2010 Moritz Bitsch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

namespace scgi {
	public class Server {
		MainLoop loop;
		RequestHandler handler;

		public delegate void RequestHandler(Request req);

		public Server(uint16 port, int max_threads, RequestHandler handler) {
			this.handler = handler;
			var service = new ThreadedSocketService(max_threads);

			try {
				service.add_inet_port(port, null);
			} catch (Error e){
				stderr.printf("Error in setting listen port: %s\n", e.message);
				return;
			}

			service.run.connect(requestHandler);
			service.start();
			(this.loop = new MainLoop(null, false)).run();
		}

		private bool requestHandler(SocketConnection conn) {
			Request req = new Request();

			var input = new DataInputStream(conn.input_stream);
			var output = new DataOutputStream(conn.output_stream);

			var builder = new StringBuilder();

			uchar b;
			try {
				while((b = input.read_byte(null)) != ':') {
					builder.append_c((char)b);
				}
			} catch (Error e) {
				stderr.printf("Error in Request handler (read_byte): %s\n", e.message);
				return true;
			}

			var length = int.parse( builder.str );
			if (length > 0) {
				var bufffer = new uchar[length];
				try {
					input.read(bufffer);
						//parse the data into our result object
						req.input = input;
						req.output = output;

						string key = null;
						var tmpBuilder = new StringBuilder();
						for (int i = 0; i<length; i++) {
							if (bufffer[i] == '\0') {
								if (key == null) {
									key = tmpBuilder.str;
								} else {
									req.params.insert(key, tmpBuilder.str);
									key = null;
								}
								//clear our builder for future use
								tmpBuilder.erase(0, -1);
							} else {
								tmpBuilder.append_c((char)bufffer[i]);
							}
						}
				} catch (Error e) {
					stderr.printf("Error in Request handler (read): %s\n", e.message);
					return true;
				}
			}

			//strip away last semicolon
			try {
				input.read_byte(null);
			} catch (Error e) {
				stderr.printf("Error in Request handler: %s\n", e.message);
				return true;
			}
			this.handler(req);
			return true;
		}
	}
}
