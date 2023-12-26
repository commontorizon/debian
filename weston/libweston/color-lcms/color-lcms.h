/*
 * Copyright 2021 Collabora, Ltd.
 * Copyright 2021 Advanced Micro Devices, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice (including the
 * next paragraph) shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef WESTON_COLOR_LCMS_H
#define WESTON_COLOR_LCMS_H

#include <lcms2.h>
#include <libweston/libweston.h>

#include "color.h"
#include "shared/helpers.h"

struct weston_color_manager_lcms {
	struct weston_color_manager base;
	cmsContext lcms_ctx;

	struct wl_list color_transform_list; /* cmlcms_color_transform::link */
	struct wl_list color_profile_list; /* cmlcms_color_profile::link */
};

static inline struct weston_color_manager_lcms *
get_cmlcms(struct weston_color_manager *cm_base)
{
	return container_of(cm_base, struct weston_color_manager_lcms, base);
}

struct cmlcms_md5_sum {
	uint8_t bytes[16];
};

struct cmlcms_color_profile {
	struct weston_color_profile base;

	/* struct weston_color_manager_lcms::color_profile_list */
	struct wl_list link;

	cmsHPROFILE profile;
	struct cmlcms_md5_sum md5sum;
};

static inline struct cmlcms_color_profile *
get_cprof(struct weston_color_profile *cprof_base)
{
	return container_of(cprof_base, struct cmlcms_color_profile, base);
}

bool
cmlcms_get_color_profile_from_icc(struct weston_color_manager *cm,
				  const void *icc_data,
				  size_t icc_len,
				  const char *name_part,
				  struct weston_color_profile **cprof_out,
				  char **errmsg);

void
cmlcms_destroy_color_profile(struct weston_color_profile *cprof_base);

/*
 * Perhaps a placeholder, until we get actual color spaces involved and
 * see how this would work better.
 */
enum cmlcms_color_transform_type {
	CMLCMS_TYPE_EOTF_sRGB = 0,
	CMLCMS_TYPE_EOTF_sRGB_INV,
	CMLCMS_TYPE__END,
};

struct cmlcms_color_transform_search_param {
	enum cmlcms_color_transform_type type;
};

struct cmlcms_color_transform {
	struct weston_color_transform base;

	/* weston_color_manager_lcms::color_transform_list */
	struct wl_list link;

	struct cmlcms_color_transform_search_param search_key;

	/* for EOTF types */
	cmsToneCurve *curve;
};

static inline struct cmlcms_color_transform *
get_xform(struct weston_color_transform *xform_base)
{
	return container_of(xform_base, struct cmlcms_color_transform, base);
}

struct cmlcms_color_transform *
cmlcms_color_transform_get(struct weston_color_manager_lcms *cm,
			   const struct cmlcms_color_transform_search_param *param);

void
cmlcms_color_transform_destroy(struct cmlcms_color_transform *xform);

#endif /* WESTON_COLOR_LCMS_H */
