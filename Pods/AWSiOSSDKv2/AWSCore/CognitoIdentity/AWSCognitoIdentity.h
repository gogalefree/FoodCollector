/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "AWSService.h"
#import "AWSCognitoIdentityModel.h"

@class BFTask;

/**
 * <fullname>Amazon Cognito</fullname><p>Amazon Cognito is a web service that delivers scoped temporary credentials to mobile devices and other untrusted environments. Amazon Cognito uniquely identifies a device and supplies the user with a consistent identity over the lifetime of an application.</p><p>Using Amazon Cognito, you can enable authentication with one or more third-party identity providers (Facebook, Google, or Login with Amazon), and you can also choose to support unauthenticated access from your app. Cognito delivers a unique identifier for each user and acts as an OpenID token provider trusted by AWS Security Token Service (STS) to access temporary, limited-privilege AWS credentials.</p><p>To provide end-user credentials, first make an unsigned call to <a>GetId</a>. If the end user is authenticated with one of the supported identity providers, set the <code>Logins</code> map with the identity provider token. <code>GetId</code> returns a unique identifier for the user.</p><p>Next, make an unsigned call to <a>GetOpenIdToken</a>, which returns the OpenID token necessary to call STS and retrieve AWS credentials. This call expects the same <code>Logins</code> map as the <code>GetId</code> call, as well as the <code>IdentityID</code> originally returned by <code>GetId</code>. The token returned by <code>GetOpenIdToken</code> can be passed to the STS operation <a href="http://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html">AssumeRoleWithWebIdentity</a> to retrieve AWS credentials.</p>
 */
@interface AWSCognitoIdentity : AWSService

@property (nonatomic, strong, readonly) AWSServiceConfiguration *configuration;

+ (instancetype)defaultCognitoIdentity;

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration;

/**
 * <p>Creates a new identity pool. The identity pool is a store of user identity information that is specific to your AWS account. The limit on identity pools is 60 per account.</p>
 *
 * @param request A container for the necessary parameters to execute the CreateIdentityPool service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityIdentityPool. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError, AWSCognitoIdentityErrorLimitExceeded.
 *
 * @see AWSCognitoIdentityCreateIdentityPoolInput
 * @see AWSCognitoIdentityIdentityPool
 */
- (BFTask *)createIdentityPool:(AWSCognitoIdentityCreateIdentityPoolInput *)request;

/**
 * <p>Deletes a user pool. Once a pool is deleted, users will not be able to authenticate with the pool.</p>
 *
 * @param request A container for the necessary parameters to execute the DeleteIdentityPool service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will be nil. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityDeleteIdentityPoolInput
 */
- (BFTask *)deleteIdentityPool:(AWSCognitoIdentityDeleteIdentityPoolInput *)request;

/**
 * <p>Gets details about a particular identity pool, including the pool name, ID description, creation date, and current number of users.</p>
 *
 * @param request A container for the necessary parameters to execute the DescribeIdentityPool service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityIdentityPool. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityDescribeIdentityPoolInput
 * @see AWSCognitoIdentityIdentityPool
 */
- (BFTask *)describeIdentityPool:(AWSCognitoIdentityDescribeIdentityPoolInput *)request;

/**
 * <p>Generates (or retrieves) a Cognito ID. Supplying multiple logins will create an implicit linked account.</p>
 *
 * @param request A container for the necessary parameters to execute the GetId service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityGetIdResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError, AWSCognitoIdentityErrorLimitExceeded.
 *
 * @see AWSCognitoIdentityGetIdInput
 * @see AWSCognitoIdentityGetIdResponse
 */
- (BFTask *)getId:(AWSCognitoIdentityGetIdInput *)request;

/**
 * <p>Gets an OpenID token, using a known Cognito ID. This known Cognito ID is returned by <a>GetId</a>. You can optionally add additional logins for the identity. Supplying multiple logins creates an implicit link.</p><p>The OpenId token is valid for 15 minutes.</p>
 *
 * @param request A container for the necessary parameters to execute the GetOpenIdToken service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityGetOpenIdTokenResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityGetOpenIdTokenInput
 * @see AWSCognitoIdentityGetOpenIdTokenResponse
 */
- (BFTask *)getOpenIdToken:(AWSCognitoIdentityGetOpenIdTokenInput *)request;

/**
 * <p>Registers (or retrieves) a Cognito <code>IdentityId</code> and an OpenID Connect token for a user authenticated by your backend authentication process. Supplying multiple logins will create an implicit linked account. You can only specify one developer provider as part of the <code>Logins</code> map, which is linked to the identity pool. The developer provider is the "domain" by which Cognito will refer to your users.</p><p>You can use <code>GetOpenIdTokenForDeveloperIdentity</code> to create a new identity and to link new logins (that is, user credentials issued by a public provider or developer provider) to an existing identity. When you want to create a new identity, the <code>IdentityId</code> should be null. When you want to associate a new login with an existing authenticated/unauthenticated identity, you can do so by providing the existing <code>IdentityId</code>. This API will create the identity in the specified <code>IdentityPoolId</code>.</p>
 *
 * @param request A container for the necessary parameters to execute the GetOpenIdTokenForDeveloperIdentity service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityGetOpenIdTokenForDeveloperIdentityResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError, AWSCognitoIdentityErrorDeveloperUserAlreadyRegistered.
 *
 * @see AWSCognitoIdentityGetOpenIdTokenForDeveloperIdentityInput
 * @see AWSCognitoIdentityGetOpenIdTokenForDeveloperIdentityResponse
 */
- (BFTask *)getOpenIdTokenForDeveloperIdentity:(AWSCognitoIdentityGetOpenIdTokenForDeveloperIdentityInput *)request;

/**
 * <p>Lists the identities in a pool.</p>
 *
 * @param request A container for the necessary parameters to execute the ListIdentities service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityListIdentitiesResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityListIdentitiesInput
 * @see AWSCognitoIdentityListIdentitiesResponse
 */
- (BFTask *)listIdentities:(AWSCognitoIdentityListIdentitiesInput *)request;

/**
 * <p>Lists all of the Cognito identity pools registered for your account.</p>
 *
 * @param request A container for the necessary parameters to execute the ListIdentityPools service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityListIdentityPoolsResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityListIdentityPoolsInput
 * @see AWSCognitoIdentityListIdentityPoolsResponse
 */
- (BFTask *)listIdentityPools:(AWSCognitoIdentityListIdentityPoolsInput *)request;

/**
 * <p>Retrieves the <code>IdentityID</code> associated with a <code>DeveloperUserIdentifier</code> or the list of <code>DeveloperUserIdentifier</code>s associated with an <code>IdentityId</code> for an existing identity. Either <code>IdentityID</code> or <code>DeveloperUserIdentifier</code> must not be null. If you supply only one of these values, the other value will be searched in the database and returned as a part of the response. If you supply both, <code>DeveloperUserIdentifier</code> will be matched against <code>IdentityID</code>. If the values are verified against the database, the response returns both values and is the same as the request. Otherwise a <code>ResourceConflictException</code> is thrown.</p>
 *
 * @param request A container for the necessary parameters to execute the LookupDeveloperIdentity service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityLookupDeveloperIdentityResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityLookupDeveloperIdentityInput
 * @see AWSCognitoIdentityLookupDeveloperIdentityResponse
 */
- (BFTask *)lookupDeveloperIdentity:(AWSCognitoIdentityLookupDeveloperIdentityInput *)request;

/**
 * <p>Merges two users having different <code>IdentityId</code>s, existing in the same identity pool, and identified by the same developer provider. You can use this action to request that discrete users be merged and identified as a single user in the Cognito environment. Cognito associates the given source user (<code>SourceUserIdentifier</code>) with the <code>IdentityId</code> of the <code>DestinationUserIdentifier</code>. Only developer-authenticated users can be merged. If the users to be merged are associated with the same public provider, but as two different users, an exception will be thrown.</p>
 *
 * @param request A container for the necessary parameters to execute the MergeDeveloperIdentities service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityMergeDeveloperIdentitiesResponse. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityMergeDeveloperIdentitiesInput
 * @see AWSCognitoIdentityMergeDeveloperIdentitiesResponse
 */
- (BFTask *)mergeDeveloperIdentities:(AWSCognitoIdentityMergeDeveloperIdentitiesInput *)request;

/**
 * <p>Unlinks a <code>DeveloperUserIdentifier</code> from an existing identity. Unlinked developer users will be considered new identities next time they are seen. If, for a given Cognito identity, you remove all federated identities as well as the developer user identifier, the Cognito identity becomes inaccessible.</p>
 *
 * @param request A container for the necessary parameters to execute the UnlinkDeveloperIdentity service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will be nil. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityUnlinkDeveloperIdentityInput
 */
- (BFTask *)unlinkDeveloperIdentity:(AWSCognitoIdentityUnlinkDeveloperIdentityInput *)request;

/**
 * <p>Unlinks a federated identity from an existing account. Unlinked logins will be considered new identities next time they are seen. Removing the last linked login will make this identity inaccessible.</p>
 *
 * @param request A container for the necessary parameters to execute the UnlinkIdentity service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will be nil. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityUnlinkIdentityInput
 */
- (BFTask *)unlinkIdentity:(AWSCognitoIdentityUnlinkIdentityInput *)request;

/**
 * <p>Updates a user pool.</p>
 *
 * @param request A container for the necessary parameters to execute the UpdateIdentityPool service method.
 *
 * @return An instance of BFTask. On successful execution, task.result will contain an instance of AWSCognitoIdentityIdentityPool. On failed execution, task.error may contain an NSError with AWSCognitoIdentityErrorDomain domian and the following error code: AWSCognitoIdentityErrorInvalidParameter, AWSCognitoIdentityErrorResourceNotFound, AWSCognitoIdentityErrorNotAuthorized, AWSCognitoIdentityErrorResourceConflict, AWSCognitoIdentityErrorTooManyRequests, AWSCognitoIdentityErrorInternalError.
 *
 * @see AWSCognitoIdentityIdentityPool
 * @see AWSCognitoIdentityIdentityPool
 */
- (BFTask *)updateIdentityPool:(AWSCognitoIdentityIdentityPool *)request;

@end
