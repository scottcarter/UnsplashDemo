//
//  ImageGroupModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/18/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Alamofire
import Foundation

class ImageGroupModel {

    // MARK: - Structs

    struct ImageError: Error {
        let description: String
        let reason: ImageErrorReason

        var localizedDescription: String {
            description
        }
    }

    // Structure returned to caller with image information
    struct ImageResult {
        let regularSizeURL: String
        let smallThumbSizeURL: String
        let largeThumbSizeURL: String
        let description: String
    }

    // MARK: - Enumerations

    enum ImageErrorReason: String {
        case alamoFireError
        case maxPageExceeded
    }

    // Options for order_by parameter
    // https://unsplash.com/documentation#list-photos
    enum ImageSort: String {
        case latest
        case oldest
        case popular
    }

    // MARK: - Functions

    func data(for url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        fetchData(url: url) { result in
            completion(result)
        }
    }

    // Fetch an array of results.
    func images(
        page: Int,
        perPage: Int,
        orderBy: ImageSort,
        completion: @escaping (Result<[ImageResult], ImageError>) -> Void
    ) {
        guard page <= Constants.Unsplash.maxPageNumber else {
            completion(.failure(.init(description: "Can't exceed \(Constants.Unsplash.maxPageNumber) for page number",
                reason: .maxPageExceeded)))
            return
        }

        let urlToRequest = requestUrl(page: page, perPage: perPage, orderBy: orderBy)

        fetchDecodable(url: urlToRequest) {[weak self] result in

            guard let self = self else {
                return
            }

            if case let .failure(error) = result {
                completion(.failure(error))
                return
            }

            guard case let .success(photoArr) = result else {
                assertionFailure("Did not get valid result")
                return
            }

            var resultArr = [ImageResult]()

            for photo in photoArr {
                let raw = photo.photoUrl.rawURL
                let description = photo.photoDescription ?? ""

                let regularSizeURL = self.urlRegularSize(from: raw)
                let smallThumbSizeURL = self.urlSmallThumbSize(from: raw)
                let largeThumbSizeURL = self.urlLargeThumbSize(from: raw)

                let result = ImageResult(regularSizeURL: regularSizeURL,
                                         smallThumbSizeURL: smallThumbSizeURL,
                                         largeThumbSizeURL: largeThumbSizeURL,
                                         description: description)
                resultArr.append(result)
            }

            // Call completion handler with results gathered
            completion(.success(resultArr))
        }
    }
}

private extension ImageGroupModel {

    // MARK: - Functions

    // Fetch Data
    func fetchData (url: String, completion: @escaping (Result<Data, Error>) -> Void) {

        // Use the default main dispatch queue for response.
        AF.request(url)
            .validate()
            .responseData { response in

                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error as Error))
                }
        }
    }

    // Fetch data and decode to Photo object array.
    func fetchDecodable (url: String, completion: @escaping (Result<[Photo], ImageError>) -> Void) {

        // Use the default main dispatch queue for response.
        AF.request(url)
            .validate()
            .responseDecodable(of: [Photo].self) { response in
                switch response.result {
                case .success:
                    completion(.success(response.value ?? []))
                case .failure:
                    // Map AFError to ImageError struct
                    // https://github.com/Alamofire/Alamofire/blob/master/Source/AFError.swift
                    let imageError = response.result.mapError { error -> ImageError in
                        ImageError(
                            description: "Alamofire error: \(error.localizedDescription)",
                            reason: .alamoFireError
                        )
                    }
                    completion(imageError)
                }
        }
    }

    func requestUrl(page: Int, perPage: Int, orderBy: ImageSort) -> String {
        guard page >= 1 else {
            assertionFailure("Pages start at 1")
            return ""
        }

        let baseUrl = "https://api.unsplash.com/photos/"
        let clientId = Constants.Unsplash.accessToken
        let url = "\(baseUrl)?client_id=\(clientId)&page=\(page)&per_page=\(perPage)&order_by=\(orderBy.rawValue)"
        return url
    }

    // Provide our custom regular size
    func urlRegularSize(from rawUrl: String) -> String {
        return "\(rawUrl)&fm=jpg&fit=crop&w=1080&q=80&fit=max"
    }

    // Small thumb size -  100 x 100
    // fit=clip: Fit without cropping or distorting the image. Resizes image to fit one of the dimensions.
    // https://docs.imgix.com/apis/url/size/fit
    func urlSmallThumbSize(from rawUrl: String) -> String {
        return "\(rawUrl)&fm=jpg&w=100&h=100&fit=clip"
    }

    // Larger thumb size - 200x200
    func urlLargeThumbSize(from rawUrl: String) -> String {
        return "\(rawUrl)&fm=jpg&w=200&h=200&fit=clip"
    }

}
