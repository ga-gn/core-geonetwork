/*
 *  Copyright (C) 2014 GeoSolutions S.A.S.
 *  http://www.geo-solutions.it
 *
 *  GPLv3 + Classpath exception
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.fao.geonet.kernel.security.shibboleth;

import javax.annotation.Nonnull;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.transaction.Transactional;

import org.apache.batik.util.resources.ResourceManager;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Group;
import org.fao.geonet.domain.LDAPUser;
import org.fao.geonet.domain.Profile;
import org.fao.geonet.domain.User;
import org.fao.geonet.domain.UserGroup;
import org.fao.geonet.kernel.security.GeonetworkAuthenticationProvider;
import org.fao.geonet.kernel.security.WritableUserDetailsContextMapper;
import org.fao.geonet.repository.GroupRepository;
import org.fao.geonet.repository.Updater;
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.utils.Log;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.provisioning.UserDetailsManager;
import org.springframework.util.StringUtils;

import jeeves.component.ProfileManager;

import java.util.*;

/**
 * @author ETj (etj at geo-solutions.it)
 * @author María Arias de Reyna (delawen)
 */
public class ShibbolethUserUtils {
    private UserDetailsManager userDetailsManager;
    private WritableUserDetailsContextMapper udetailsmapper;

    static MinimalUser parseUser(ServletRequest request, ResourceManager resourceManager, ProfileManager profileManager,
            ShibbolethUserConfiguration config) {
        return MinimalUser.create(request, config);
    }

    protected static String getHeader(HttpServletRequest req, String name, String defValue) {

        if (name == null || name.trim().isEmpty()) {
            return defValue;
        }

        String value = req.getHeader(name);

        if (value == null)
            return defValue;

        if (value.length() == 0)
            return defValue;

        return value;
    }

    /**
     * @return the inserted/updated user or null if no valid user found or any error
     *         happened
     */
    @Transactional
    protected UserDetails setupUser(ServletRequest request, ShibbolethUserConfiguration config) throws Exception {
        UserRepository userRepository = ApplicationContextHolder.get().getBean(UserRepository.class);
        GroupRepository groupRepository = ApplicationContextHolder.get().getBean(GroupRepository.class);
        UserGroupRepository userGroupRepository = ApplicationContextHolder.get().getBean(UserGroupRepository.class);
        GeonetworkAuthenticationProvider authProvider = ApplicationContextHolder.get()
                .getBean(GeonetworkAuthenticationProvider.class);

        // Read in the data from the headers
        HttpServletRequest req = (HttpServletRequest) request;

        String username = getHeader(req, config.getUsernameKey(), "");
        String surname = getHeader(req, config.getSurnameKey(), "");
        String firstname = getHeader(req, config.getFirstnameKey(), "");
        String organisation = getHeader(req, config.getOrganisationKey(), "");
        String email = getHeader(req, config.getEmailKey(), "");
        String arraySeparator = config.getArraySeparator();
        String roleGroupSeparator = config.getRoleGroupSeparator();

        Profile profile = Profile.findProfileIgnoreCase(getHeader(req, config.getProfileKey(), ""));
        String group = config.getGroupKey();
        String profileUpdate = config.getProfileKey();
        if (username != null && username.trim().length() > 0) {
            if(profileUpdate != null){
                switch (profileUpdate) {
                    case "EDITOR":
                        profile = Profile.Editor;
                        break;
                    case "ADMINISTRATOR":
                        profile = Profile.Administrator;
                        break;
                    case "REVIEWER":
                        profile = Profile.Reviewer;
                        break;
                    default:
                        profile = Profile.Guest;
                        break;
                }
            }
            if (profile == null) {
                profile = Profile.Guest;
            }
            if (group == null || group.trim().isEmpty()) {
                group = config.getDefaultGroup();
            }

            // FIXME: needed? only accept the first 256 chars
            if (username.length() > 256) {
                username = username.substring(0, 256);
            }

            // Create or update the user
            User user = new User();
            try {
                user = (User) authProvider.loadUserByUsername(username);
            } catch (UsernameNotFoundException e) {
                user.setUsername(username);
                user.setSurname(surname);
                user.setName(firstname);
                user.setOrganisation(organisation);
                user.setProfile(profile);
                user.getEmailAddresses().add(email);
            }

            if (udetailsmapper != null) {
                // If is not null, we may want to write to ldap if user does not exist
                LDAPUser ldapUserDetails = null;
                try {
                    ldapUserDetails = (LDAPUser) userDetailsManager.loadUserByUsername(username);
                } catch (Throwable t) {
                    Log.error(Geonet.GEONETWORK, "Shibboleth setupUser error: " + t.getMessage(), t);
                }

                if (ldapUserDetails == null) {
                    ldapUserDetails = new LDAPUser(username);
                    ldapUserDetails.getUser().setName(firstname).setSurname(surname);
                    ldapUserDetails.getUser().setOrganisation(organisation);
                    ldapUserDetails.getUser().setProfile(profile);
                    ldapUserDetails.getUser().getEmailAddresses().clear();
                    if (StringUtils.isEmpty(email)) {
                        ldapUserDetails.getUser().getEmailAddresses().add(username + "@unknownIdp");
                    } else {
                        ldapUserDetails.getUser().getEmailAddresses().add(email);
                    }
                }

                udetailsmapper.saveUser(ldapUserDetails);

                user = ldapUserDetails.getUser();
            } else {
                User repoUser = userRepository.findOneByUsername(user.getUsername());
                if (repoUser == null) {
                    userRepository.saveAndFlush(user);
                    Group repoGroup = groupRepository.findByName(group);
                    List<GroupElem> groups = new LinkedList<>();
                    if (repoGroup != null) {
                        groups.add(new GroupElem(profile.name(), repoGroup.getId()));
                        addUserGroups(user, groups);
                    }
                } else {
                    Profile repoProfile = repoUser.getProfile();
                    if (repoProfile == null) {
                        repoProfile = Profile.Editor;
                    }
                    final Profile updatedProfile = repoProfile;
                    Log.warning(Geonet.DATA_MANAGER, "Shib, user profile: " + updatedProfile);
                    final String updatedSurname = surname;
                    final String updatedFirstName = firstname;
                    final String updatedEmail = email;
                    user = userRepository.update(repoUser.getId(), new Updater<User>() {
                        @Override
                        public void apply(@Nonnull User updatedUser) {
                            updatedUser.setSurname(updatedSurname);
                            updatedUser.setName(updatedFirstName);
                            updatedUser.setProfile(updatedProfile);
                            updatedUser.getEmailAddresses().add(updatedEmail);
                        }
                    });
                }
            }
            return user;
        }
        return null;
    }

    private void addUserGroups(final User user, List<GroupElem> userGroups) throws Exception {

        final GroupRepository groupRepository = ApplicationContextHolder.get().getBean(GroupRepository.class);
        final UserGroupRepository userGroupRepository = ApplicationContextHolder.get().getBean(UserGroupRepository.class);

        Set<String> listOfAddedProfiles = new HashSet<String>();
        Collection<UserGroup> newUserGroups = new ArrayList<UserGroup>();

        for (GroupElem element : userGroups) {
            Integer groupId = element.getId();
            Group group = groupRepository.getOne(groupId);
            String profile = element.getProfile();
            final UserGroup userGroup;
            userGroup = new UserGroup().setGroup(group).setProfile(Profile.findProfileIgnoreCase(profile)).setUser(user);
            String key = profile + group.getId();
            if (!listOfAddedProfiles.contains(key)) {
                newUserGroups.add(userGroup);
                listOfAddedProfiles.add(key);
            }
        }
        userGroupRepository.saveAll(newUserGroups);
    }

    public static class MinimalUser {

        private String username;
        private String name;
        private String surname;
        private String organisation;
        private String profile;

        static MinimalUser create(ServletRequest request, ShibbolethUserConfiguration config) {

            // Read in the data from the headers
            HttpServletRequest req = (HttpServletRequest) request;

            String username = getHeader(req, config.getUsernameKey(), "");
            String surname = getHeader(req, config.getSurnameKey(), "");
            String firstname = getHeader(req, config.getFirstnameKey(), "");
            String organisation = getHeader(req, config.getOrganisationKey(), "");
            String profile = getHeader(req, config.getProfileKey(), "");

            if (username.trim().length() > 0) {
                MinimalUser user = new MinimalUser();
                user.setUsername(username);
                user.setName(firstname);
                user.setSurname(surname);
                user.setOrganisation(organisation);
                user.setProfile(profile);
                return user;
            } else {
                return null;
            }
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getSurname() {
            return surname;
        }

        public void setSurname(String surname) {
            this.surname = surname;
        }

        public String getOrganisation() {
            return organisation;
        }

        public void setOrganisation(String organisation) {
            this.organisation = organisation;
        }

        public String getProfile() {
			return profile;
		}

        public void setProfile(String profile) {
            this.profile = profile;
        }
    }
}

class GroupElem {

    private String profile;
    private Integer id;

    public GroupElem(String profile, Integer id) {
        this.id = id;
        this.profile = profile;
    }

    public String getProfile() { return profile; }

    public Integer getId() { return id; }
}
