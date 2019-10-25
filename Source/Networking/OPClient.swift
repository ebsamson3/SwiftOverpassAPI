//
//  OPClient.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

// A class for making requests to an Overpass API endpoint and decoding the subsequent response
public class OPClient {
	
	/*
		These are the endpoints listed at:
		https://wiki.openstreetmap.org/wiki/Overpass_API
		
		Users can also define a custom endpoint.
	*/
	public enum Endpoint {
		case main, main2, french, swiss, kumiSystems, taiwan
		case custom(urlString: String)
		
		public var urlString: String {
			switch self {
			case .main:
				return "https://lz4.overpass-api.de/api/interpreter"
			case .main2:
				return "https://z.overpass-api.de/api/interpreter"
			case .french:
				return "http://overpass.openstreetmap.fr/api/interpreter"
			case .swiss:
				return "http://overpass.osm.ch/api/interpreter"
			case .kumiSystems:
				return "https://overpass.kumi.systems/api/interpreter"
			case .taiwan:
				return "https://overpass.nchc.org.tw"
			case .custom(let urlString):
				return urlString
			}
		}
	}
	
	private let session: URLSession
	
	// Store a reference to any url task being performed in case it needs to be cancelled.
	private var task: URLSessionDataTask?
	
	// Store the current query
	private var query: String? = nil
	
	// The selected endpoint for the overpass api post request
	public var endpoint: Endpoint
	
	// Getting and setting the url string. Has the same effect as setting the endpoint.
	public var endpointUrlString: String {
		set {
			self.endpoint = .custom(urlString: newValue)
		}
		get {
			return endpoint.urlString
		}
	}
	
	// The queue on which decoding operations are run
	private lazy var elementDecodingQueue: OperationQueue = {
	  var queue = OperationQueue()
	  queue.name = "Element decoding queue"
	  queue.maxConcurrentOperationCount = 1
	  return queue
	}()
	
	// Initializing the client with an endpoint and a url session. I've found the kumi systems endpoint to be the least restrictive in terms of usage.
	public init(
		endpoint: Endpoint = .kumiSystems,
		session: URLSession = URLSession.shared)
	{
		self.session = session
		self.endpoint = endpoint
		
	}
	
	// Initialized a client with an endpoint url string and a url session
	public init(
		endpointUrlString: String,
		session: URLSession = URLSession.shared)
	{
		self.session = session
		self.endpoint = .custom(urlString: endpointUrlString)
	}
	
	// A fetch request to the api. Requires a query that is written in the Overpass API language. For simple queries, the OverpassQueryBuilder class can be used to conviniently build queries.
	public func fetchElements(
		query: String,
		completion: @escaping (OPClientResult) -> Void)
	{
		// Store the current query and cancel any ongoing fetches by the client
		self.query = query
		cancelFetch()
		
		// Convert the endpoint URL string into a URL
		guard let url = URL(string: endpointUrlString) else {
			return
		}
		
		// encode the query string into data
		let data = query.data(using: .utf8)
		
		// Build the Overpass API request. The request posts your data containing the Overpass API code to the client's endpoint
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = data
		
		// Sending the URL request
		task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			
			// Peform the completion handler on the main thread
			let completionOnMain: (OPClientResult) -> Void = { result in
				DispatchQueue.main.async {
					completion(result)
				}
			}
			
			// Remove the stored reference to the task
			self?.task = nil
			
			// If the stored query has changed since last request finished, ignore the finished request.
			guard self?.query == query else {
				return
			}
			
			// If the response returned an error, abort
			if let error = error {
				completionOnMain(.failure(error))
				return
			}
			
			// If an unsuccessful response is recieved, abort
			if
				let httpResponse = response as? HTTPURLResponse,
				httpResponse.statusCode != 200
			{
				completionOnMain(.failure(OPRequestError.badResponse(httpResponse)))
				return
			}
			
			// If the request returned nil data, abort
			guard let data = data else {
				completionOnMain(.failure(OPRequestError.nilData))
				return
			}
			
			// initialize an operation to return the decoded data
			let operation = OPDecodingOperation(data: data)
			
			// On completion of the operation, if no errors are thrown and the oepration wasn't cancelled, pass the decoded elements to the completion handler.
			operation.completionBlock = {
				
				DispatchQueue.main.async {
					if operation.isCancelled {
						return
					}
					if let error = operation.error {
						completion(.failure(error))
						return
					}
					completion(.success(operation.elements))
				}
			}
			
			// Queue up the operation
			self?.elementDecodingQueue.addOperation(operation)
		}
		
		// Run the asynchronous request to the Overpass API endpoint
		task?.resume()
	}
	
	// Cancel the current fetch/decoding operation
	public func cancelFetch() {
		task?.cancel()
		elementDecodingQueue.cancelAllOperations()
	}
}
