/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

(function() {
  goog.provide('gn_mdactions_service');




  goog.require('gn_category');
  goog.require('gn_popup');
  goog.require('gn_share');


  var module = angular.module('gn_mdactions_service', [
    'gn_share', 'gn_category', 'gn_popup', 'checklist-model'
  ]);

  module.service('gnMetadataActions', [
    '$rootScope',
    '$timeout',
    '$location',
    'gnHttp',
    'gnMetadataManager',
    'gnAlertService',
    'gnSearchSettings',
    'gnUtilityService',
    'gnShareService',
    'gnPopup',
    'gnMdFormatter',
    '$translate',
    '$q',
    '$http',
    'gnConfig',
    function($rootScope, $timeout, $location, gnHttp,
             gnMetadataManager, gnAlertService, gnSearchSettings,
             gnUtilityService, gnShareService, gnPopup, gnMdFormatter,
             $translate, $q, $http, gnConfig) {

      var windowName = 'geonetwork';
      var windowOption = '';
      var translations = null;
      $translate(['metadataPublished', 'metadataUnpublished',
        'metadataPublishedError', 'metadataUnpublishedError']).then(function(t) {
        translations = t;
      });
      var alertResult = function(msg) {
        gnAlertService.addAlert({
          msg: msg,
          type: 'success'
        });
      };

      /**
       * Open a popup and compile object content.
       * Bind to an event to close the popup.
       * @param {Object} o popup config
       * @param {Object} scope to build content uppon
       * @param {string} eventName
       */
      var openModal = function(o, scope, eventName) {
        var popup = gnPopup.create(o, scope);
        var myListener = $rootScope.$on(eventName,
            function(e, o) {
              $timeout(function() {
                popup.close();
              }, 0);
              myListener();
            });
      };
      
      var callBatch = function(service) {
        return gnHttp.callService(service).then(function(data) {
          alertResult(data.data);
        });
      };

      /**
       * Duplicate a metadata that can be a new child of the source one.
       * @param {string} id
       * @param {boolean} child
       */
      var duplicateMetadata = function(id, child) {
        var url = 'catalog.edit#/';
        if (id) {
          if (child) {
            url += 'create?childOf=' + id;
          } else {
            url += 'create?from=' + id;
          }
        }
        window.open(url, '_blank');
      };

      /**
       * Export as PDF (one or selection). If params is search object, we check
       * for sortBy and sortOrder to process the print. If it is a string
       * (uuid), we print only one metadata.
       * @param {Object|string} params
       */
      this.metadataPrint = function(params, bucket) {
        var url;
        if (angular.isObject(params) && params.sortBy) {
          url = gnHttp.getService('mdGetPDFSelection');
          url += '?sortBy=' + params.sortBy;
          if (params.sortOrder) {
            url += '&sortOrder=' + params.sortOrder;
          }
          url += '&bucket=' + bucket;
          location.replace(url);
        }
        else if (angular.isString(params)) {
          gnMdFormatter.getFormatterUrl(null, null, params).then(function(url) {
            $http.get(url, {
              headers: {
                Accept: 'text/html'
              }
            });
          });
        }
      };

      /**
       * Export one metadata to RDF format.
       * @param {string} uuid
       */
      this.metadataRDF = function(uuid, approved) {
        var url = gnHttp.getService('mdGetRDF') + '?uuid=' + uuid;

        url += angular.isDefined(approved) ?
            '&approved=' + approved : '';

        location.replace(url);
      };

      /**
       * Export to MEF format (one or selection). If uuid is provided, export
       * one metadata, else export the whole selection.
       * @param {string} uuid
       */
      this.metadataMEF = function(uuid, bucket, approved) {

        var url = gnHttp.getService('mdGetMEF') + '?version=2';
        url += angular.isDefined(uuid) ?
            '&uuid=' + uuid : '&format=full';
        url += angular.isDefined(bucket) ?
            '&bucket=' + bucket : '';
        url += angular.isDefined(approved) ?
            '&approved=' + approved : '';

        location.replace(url);
      };

      this.openExportColumns = function(scope, bucket) {

		  scope.columns = [
			  'Title',
			  'Abstract',
			  'MetadataScope',
			  'ParentMetadata',
			  'CitationDate',
			  'Purpose',
			  'Status',
			  'Keyword',
			  'Keyword-Thesaurus',
			  'MaintenanceFrequency',
			  'TopicCategory',
			  'ResponsibleParty',
			  'ResourceContact',
			  'MetadataContact',
			  'GeographicalExtent',
			  'SpatialExtentDescription',
			  'HorizontalSpatialReferenceSystem',
			  'VerticalExtent',
			  'VerticalCRS',
			  'TemporalExtent',
			  'MetadataSecurityConstraint',
			  'SecurityConstraint',
			  'ResourceLegalConstraint',
			  'UseLimitations',
			  'DistributionLink',
			  'DistributionFormat',
			  'DataStorageLink',
			  //'DataStorageFormat',
			  'Lineage',
			  'SourceDescription',
			  'AssociatedResourcesLink',
			  'AdditionalInfo',
			  'ServiceParameter',
			  'ConnectPoint',
			  'ServiceType',
			  'ServiceTypeVersion',
			  'CouplingType',
			  'OperationName',
			  'DistributedComputingPlatform',
			  'OperationDescription'
		  ];
		 
		  scope.csv = {
			columns: []
		  };
		  scope.exporting = false;
		  scope.errMsg = false;
		  scope.errMsgStr = '';
		  
		  scope.checkAll = function() {
			scope.csv.columns = angular.copy(scope.columns);
		  };
		  scope.uncheckAll = function() {
			scope.csv.columns = [];
		  };
		  
		  scope.fileloc;
		  
		  scope.exportCSV = function() {
			  console.log('export....');
			  return $http.put('../api/records/download/csv?bucket=' + bucket + '&exportParams=' + scope.csv.columns)
						  .then(function(response){
							  scope.fileloc = response.data;
							  scope.exporting = true;
							  checkIsCompleted();	
						  });
		  };
		  
		  
		  function checkIsCompleted(){
			  
			// Check if completed
			return $http.get('../api/records/download/status').
				success(function(data) {
					
					isCompleted = data;
				  if (!isCompleted) {
					$timeout(checkIsCompleted, 1000);
				  }else{
					  return $http.get('../api/records/download/csv?filename=' +  encodeURIComponent(scope.fileloc)).success(function(response) {
								saveFile(response);
						})
						.error(function(err){
							scope.exporting = false;
							scope.errMsg = true;
							scope.errMsgStr = err;
						});
				  }
				});
		  };
		  
		  function saveFile(response){
			 
			  	var dataBlob = response;
				if (window.navigator && window.navigator.msSaveOrOpenBlob) {
				  // for IE
				  
					var csvData = new Blob([content], { type: 'text/csv' });
				   	window.navigator.msSaveOrOpenBlob(dataBlob, 'metadata_records.csv');
				} else {
				   
					// for Non-IE (chrome, firefox etc.)
					var binaryData = [];
					binaryData.push(dataBlob);
					var urlObject = window.URL.createObjectURL(new Blob(binaryData, {type: "text/csv"}))
	
					var downloadLink = angular.element('<a>Download</a>');
					downloadLink.css('display','none');
					downloadLink.attr('href', urlObject);
					downloadLink.attr('download', 'metadata_records.csv');
					angular.element(document.body).append(downloadLink);
					downloadLink[0].click();
	
					// cleanup
					downloadLink.remove();
					URL.revokeObjectURL(urlObject);
				}
				scope.exporting = false;
		  };
		  
        openModal({
          title: 'Column Selection',
          content: '<div>' + 
		  '<button type="button" class="btn btn-default btn-sm" ng-click="checkAll()">Check all</button>&nbsp;' + 
		  '<button type="button" class="btn btn-default btn-sm" ng-click="uncheckAll()">Uncheck all</button>&nbsp;' +
		  '<button type="button" class="btn btn-default btn-sm" ng-click="exportCSV()">Export</button></div>' +
		  '<div style="padding-left: 50px"><i class="fa fa-spinner fa-spin fa-3x fa-fw" ng-if="exporting"></i></div>' +
		  '<div style="padding-left: 10px;color:red" ng-if="errMsg"><label>{{errMsgStr}}</label></div>' +
		  '<div ng-repeat="c in columns">' + 
		  '<input type="checkbox" checklist-model="csv.columns" checklist-value="c">&nbsp;<label>{{c}}</label></div>',
          className: ''
        }, scope, 'exportSelection');
      };
      this.validateMd = function(md, bucket) {

        $rootScope.$broadcast('operationOnSelectionStart');
        if (md) {
          return gnMetadataManager.validate(md.getId()).then(function() {
            $rootScope.$broadcast('operationOnSelectionStop');
            $rootScope.$broadcast('search');
          });
        } else {
          return gnHttp.callService('../api/records/validate?' +
              'bucket=' + bucket, null, {
                    method: 'PUT'
                  }).then(function(data) {
            alertResult(data.data);
            $rootScope.$broadcast('operationOnSelectionStop');
            $rootScope.$broadcast('search');
          });
        }
      };

      this.deleteMd = function(md, bucket) {
        $rootScope.$broadcast('operationOnSelectionStart');
        if (md) {
          return gnMetadataManager.remove(md.getId()).then(function() {
            $rootScope.$broadcast('mdSelectNone');
            $rootScope.$broadcast('operationOnSelectionStop');
            // TODO: Here we may introduce a delay to not display the deleted
            // record in results.
            // https://github.com/geonetwork/core-geonetwork/issues/759
            $rootScope.$broadcast('search');
          });
        }
        else {
          return $http.delete('../api/records?' +
              'bucket=' + bucket).then(function() {
            $rootScope.$broadcast('mdSelectNone');
            $rootScope.$broadcast('operationOnSelectionStop');
            $rootScope.$broadcast('search');
          });
        }
      };


      this.openPrivilegesPanel = function(md, scope) {
        gnUtilityService.openModal({
          title: $translate.instant('privileges') + ' - ' +
              (md.title || md.defaultTitle),
          content: '<div gn-share="' + md.getId() + '"></div>',
          className: 'gn-privileges-popup'
        }, scope, 'PrivilegesUpdated');
      };

      this.openUpdateStatusPanel = function(scope, statusType, t, statusToBe, label) {
        scope.task = t;
        scope.statusToSelect = statusToBe;
        gnUtilityService.openModal({
          title: 'mdStatusTitle-' + label,
          content: '<div data-gn-metadata-status-updater="md" ' +
                        'data-status-to-select="' + statusToBe +
                        '" data-status-type="' + statusType + '" task="t"></div>'
        }, scope, 'metadataStatusUpdated');
      };

      this.startWorkflow = function(md, scope) {
        return $http.put('../api/records/' + md.getId() +
            '/status', {status: 1, changeMessage: 'Enable workflow'}).then(
            function(response) {
              gnMetadataManager.updateMdObj(md);
              scope.$emit('metadataStatusUpdated', true);
              scope.$emit('StatusUpdated', {
                msg: $translate.instant('metadataStatusUpdatedWithNoErrors'),
                timeout: 2,
                type: 'success'});
            }, function(response) {
              scope.$emit('metadataStatusUpdated', false);


              scope.$emit('StatusUpdated', {
                title: $translate.instant('metadataStatusUpdatedErrors'),
                error: response.data,
                timeout: 0,
                type: 'danger'});
            });
      };

      this.openPrivilegesBatchPanel = function(scope, bucket) {
        gnUtilityService.openModal({
          title: 'privileges',
          content: '<div gn-share="" ' +
              'gn-share-batch="true" ' +
              'selection-bucket="' + bucket + '"></div>',
          className: 'gn-privileges-popup'
        }, scope, 'PrivilegesUpdated');
      };
      this.openBatchEditing = function(scope) {
        $location.path('/batchediting');
      };
      this.openCategoriesBatchPanel = function(bucket, scope) {
        gnUtilityService.openModal({
          title: 'categories',
          content: '<div gn-batch-categories="" ' +
              'selection-bucket="' + bucket + '"></div>'
        }, scope, 'CategoriesUpdated');
      };

      this.openTransferOwnership = function(md, bucket, scope) {
        var uuid = md ? md.getUuid() : '';
        var ownerId = md ? md.getOwnerId() : '';
        var groupOwner = md ? md.getGroupOwner() : '';
        gnUtilityService.openModal({
          title: 'transferOwnership',
          content: '<div gn-transfer-ownership="' + uuid +
              '" gn-transfer-md-owner="' + ownerId + '" ' +
              '" gn-transfer-md-group-owner="' + groupOwner + '" ' +
              'selection-bucket="' + bucket + '"></div>'
        }, scope, 'TransferOwnershipDone');
      };
      /**
       * Duplicate the given metadata. Open the editor in new page.
       * @param {string} md
       */
      this.duplicate = function(md) {
        duplicateMetadata(md.getId(), false);
      };

      /**
       * Create a child of the given metadata. Open the editor in new page.
       * @param {string} md
       */
      this.createChild = function(md) {
        duplicateMetadata(md.getId(), true);
      };

      /**
       * Update publication on metadata (one or selection).
       * If a md is provided, it update publication of the given md, depending
       * on its current state. If no metadata is given, it updates the
       * publication on all selected metadata to the given flag (on|off).
       * @param {Object|undefined} md
       * @param {string} flag
       * @return {*}
       */
      this.publish = function(md, bucket, flag, scope, internal) {
        if (md) {
          flag = (md.isPublished() || md.isPublishedInternal()) ? 'off' : 'on';
        }

        scope.isMdWorkflowEnable = gnConfig['metadata.workflow.enable'];

        //Warn about possible workflow changes on batch changes
        // or when record is not approved
        if((!md || md.mdStatus != 2) && flag === 'on' && scope.isMdWorkflowEnable) {
          if(!confirm($translate.instant('warnPublishDraft'))){
            return;
          }
        }

        scope.$broadcast('operationOnSelectionStart');
        var onOrOff = flag === 'on';

        return gnShareService.publish(
            angular.isDefined(md) ? md.getId() : undefined,
            angular.isDefined(md) ? undefined : bucket,
            onOrOff, $rootScope.user, internal)
            .then(
            function(response) {
              if (response.data !== '') {
                scope.processReport = response.data;

                // A report is returned
                gnUtilityService.openModal({
                  title: onOrOff ? translations.metadataPublished :
                    translations.metadataUnpublished,
                  content: '<div gn-batch-report="processReport"></div>',
                  className: 'gn-privileges-popup',
                  onCloseCallback: function() {
                    scope.$emit('PrivilegesUpdated', true);
                    scope.$broadcast('operationOnSelectionStop');
                    scope.processReport = null;
                  }
                }, scope, 'PrivilegesUpdated');

              } else {
                scope.$emit('PrivilegesUpdated', true);
                scope.$broadcast('operationOnSelectionStop');
                scope.$emit('StatusUpdated', {
                  msg: onOrOff ? translations.metadataPublished :
                    translations.metadataUnpublished,
                  timeout: 0,
                  type: 'success'});
              }

              if (md) {
                md.publish();
              }
            }, function(response) {
              scope.$emit('PrivilegesUpdated', false);
              scope.$broadcast('operationOnSelectionStop');
              scope.$emit('StatusUpdated', {
                title: onOrOff ? translations.metadataPublishedError :
                  translations.metadataUnpublishedError,
                error: response.data,
                timeout: 0,
                type: 'danger'});
            });

      };

      this.retire = function(bucket, scope){
        $rootScope.$broadcast('operationOnSelectionStart');
        $http.put('../api/records/retire?bucket=' + bucket).then(function() {
            checkRetireStatus();            
        });
      }

      function checkRetireStatus(){
        
        // Check if completed
        return $http.get('../api/records/retire/status').
          then(function(res) {
           
            isCompleted = res.data;
            if (!isCompleted) {
              $timeout(checkRetireStatus, 1000);
            } else {
              $rootScope.$broadcast('operationOnSelectionStop');
              $rootScope.$broadcast('resetSearch');
              return $http.get('../api/records/retire/report')
                .then(function(report) {
                  var holder = reportHTML(report.data);
                  $rootScope.$broadcast('StatusUpdated', { title: "Retiring records report",  message: holder.innerHTML, timeout: 500 });
                });
            }
            
          });
          
        };


      this.assignGroup = function(metadataId, groupId) {
        var defer = $q.defer();
        $http.put('../api/records/' + metadataId +
            '/group', groupId)
            .success(function(data) {
              defer.resolve(data);
            })
            .error(function(data) {
              defer.reject(data);
            });
        return defer.promise;
      };

      this.assignCategories = function(metadataId, categories) {
        var defer = $q.defer();
        $http.get('../records/' + metadataId +
                  '/tags?id=' + categories.join('&id='))
            .success(function(data) {
              defer.resolve(data);
            })
            .error(function(data) {
              defer.reject(data);
            });
        return defer.promise;
      };

      this.startVersioning = function(metadataId) {
        var defer = $q.defer();
        $http.get('md.versioning.start?id=' + metadataId)
            .success(function(data) {
              defer.resolve(data);
            })
            .error(function(data) {
              defer.reject(data);
            });
        return defer.promise;
      };

      /**
       * Get html formatter link for the given md
       * @param {Object} md
       */
      this.getPermalink = function(md) {
        //var url = $location.absUrl().split('#')[0] + '#/metadata/' + md.getUuid();
    	  
        var url;
        
        if(md.getType() == 'service'){
          url = "https://pid.geoscience.gov.au/service/ga/"+ md.geteCatId();
        }else{
          url = "https://pid.geoscience.gov.au/dataset/ga/"+ md.geteCatId();
        }
        gnUtilityService.getPermalink(md.title || md.defaultTitle, url);
      };

      /**
       * Index the current selection of metadata records.
       * @param {String} bucket
       */
      this.indexSelection = function(bucket) {
        return $http.get('../api/records/index', {
          params: {
            bucket: bucket
          }
        }).then(function(response) {
          var res = response.data;
          gnAlertService.addAlert({
            msg: $translate.instant('selection.indexing.count', res),
            type: res.success ? 'success' : 'danger'
          });
        }, function(response) {
          gnAlertService.addAlert({
            msg: $translate.instant('selection.indexing.error'),
            type: 'danger'
          });
        });
      };

      /**
       * Validates the current selection of metadata records.
       * @param {String} bucket
       */
      this.validateMdInspire = function(bucket) {

        $rootScope.$broadcast('operationOnSelectionStart');
        $rootScope.$broadcast('inspireMdValidationStart');

        return gnHttp.callService('../api/records/validate/inspire?' +
          'bucket=' + bucket, null, {
          method: 'PUT'
        }).then(function(data) {
          $rootScope.$broadcast('inspireMdValidationStop');
          $rootScope.$broadcast('operationOnSelectionStop');
          $rootScope.$broadcast('search');
        });

      };

      /**
       * Bulk DOI creation
       */
      this.bulkDOICreate = function(bucket){
        $rootScope.$broadcast('operationOnSelectionStart');
        $http.put('../api/records/doi/bulk?bucket=' + bucket).then(function() {
            console.log('bulk DOI Create....');
            checkDOICreateCompleted();            
        });
        
      }

      function checkDOICreateCompleted(){
        
        // Check if completed
        return $http.get('../api/records/doi/status').
          then(function(res) {           
            isCompleted = res.data;
            if (!isCompleted) {
              $timeout(checkDOICreateCompleted, 1000);
            } else {
              $rootScope.$broadcast('operationOnSelectionStop');
              $rootScope.$broadcast('resetSearch');
              return $http.get('../api/records/doi/report')
                .then(function(report) {
                  var holder = reportHTML(report.data);
                  $rootScope.$broadcast('StatusUpdated', { title: "Bulk DOI creation report", message: holder.innerHTML, timeout: 500 });
                });
            }            
          });          
        };

        function reportHTML(data){

          var holder = document.createElement('div');

          angular.forEach(data, function(value, key){
            var str = document.createElement('strong');
            str.innerText = "eCatId: " + key + ", ";
            var p = document.createElement('p');
            p.innerText = value;
            holder.appendChild(str);
            holder.appendChild(p);
          });

          return holder;
        }

      /**
       * Format a CRS description object for rendering
       * @param {Object} crsDetails expected keys: code, codeSpace, name
       */
      this.formatCrs = function(crsDetails) {
        var crs = (crsDetails.codeSpace && crsDetails.codeSpace + ':') +
            crsDetails.code;
        if (crsDetails.name) return crsDetails.name + ' (' + crs + ')';
        else return crs;
      };
    }]);
})();
