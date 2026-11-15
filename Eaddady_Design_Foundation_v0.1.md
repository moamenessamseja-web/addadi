# Ɛaddady --- Design Foundation & UI Specification

**Version:** 0.1\
**Product:** عَدّادي\
**Design direction:** Calm Utility\
**Status:** Foundation draft for implementation\
**Functional source:** User-provided README

------------------------------------------------------------------------

## 1. Product definition

Ɛaddady is an offline-first personal utility-meter tracking tool. It
records electricity, water, and gas readings; optionally attaches a
local photo to each reading; calculates consumption from the same
meter's previous valid reading; and alerts the user when consumption
exceeds a configurable threshold.

It is not a bill-payment portal and does not connect to utility
companies.

### Product promise

**اعرف استهلاكك قبل وصول الفاتورة.**

### Core experience

1.  See all meters and their current states.
2.  Record a new reading manually or with a photo.
3.  Understand consumption trends and unusual increases.
4.  Manage meters, properties, thresholds, preferences, and local
    exports.

------------------------------------------------------------------------

## 2. Seven design competencies applied

  -----------------------------------------------------------------------
  Competency              Applied design decision Validation question
  ----------------------- ----------------------- -----------------------
  Visual Hierarchy        Reading and consumption Can a user identify the
                          are visually distinct;  meter state and latest
                          alerts are prominent    consumption in a few
                          but not alarmist.       seconds?

  Information             Property, meter type,   Can two electricity
  Architecture            reading, consumption,   meters in different
                          and alert state remain  places be understood as
                          separate concepts.      separate records?

  Visual Language         Calm neutral surfaces,  Does the interface feel
                          dark ink,               consistent without
                          utility-specific        making every card look
                          accents, restrained     identical?
                          warning colors.         

  Component Composition   Reusable meter cards,   Can the same component
                          metric rows, status     represent different
                          chips, reading fields,  utilities and states
                          and alert panels.       without layout hacks?

  UX Design               Short manual-entry      Can a user save a
                          flow, optional photo    correct reading without
                          evidence, explicit      needing an account or
                          reset/replacement       internet?
                          handling.               

  Design to Development   Tokenized dimensions,   Can Flutter
                          explicit RTL/LTR        implementation follow
                          boundaries, defined     the specification
                          component states.       predictably?

  Design Critique         Every screen is         Does each visible
                          reviewed for hierarchy, element earn its space
                          density, readability,   and help the user
                          accessibility, and edge complete a task?
                          cases.                  
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 3. Design principles

1.  **Offline-first is visible in the experience:** no core flow depends
    on connectivity.
2.  **One meter, one history:** comparisons are always meter-to-itself.
3.  **Reading is not consumption:** cumulative meter reading and period
    consumption must never be visually conflated.
4.  **Evidence stays attached:** a photo, timestamp, and numeric reading
    belong to the same saved record.
5.  **No false certainty:** a spike alert is a warning for review, not a
    diagnosis of the cause.
6.  **Progressive disclosure:** show the essential state first; expose
    detailed history and configuration when requested.
7.  **Accessible contrast:** utility colors supplement labels and icons;
    color alone never communicates status.

------------------------------------------------------------------------

## 4. Direction and design tokens

### 4.1 Color palette --- proposed

These values are initial design tokens, not final brand approvals.

  Token                    Proposed value   Purpose
  ------------------------ ---------------- -------------------------------------
  `color.brand.900`        `#12304A`        Primary text, strong navigation
  `color.brand.700`        `#176B70`        Primary actions and selected states
  `color.brand.100`        `#E2F2F0`        Soft brand surfaces
  `color.surface`          `#FFFFFF`        Cards and primary surfaces
  `color.canvas`           `#F5F7FA`        Main screen background
  `color.text.primary`     `#172B3A`        Main text
  `color.text.secondary`   `#687887`        Supporting text
  `color.border`           `#E1E7ED`        Dividers and outlines
  `color.electricity`      `#D99A24`        Electricity identity
  `color.water`            `#278BCB`        Water identity
  `color.gas`              `#D97832`        Gas identity
  `color.success`          `#27845B`        Stable/complete state
  `color.warning`          `#B87918`        Elevated consumption / attention
  `color.danger`           `#B84545`        Invalid or critical state

Utility colors identify the utility type. Status colors identify the
condition. Do not use the same color role for both.

### 4.2 Typography --- proposed

Use a legible Arabic UI font already available and licensed in the
project. Candidate: **IBM Plex Sans Arabic** or **Noto Sans Arabic**.
Confirm actual font availability before implementation.

Suggested hierarchy: - Screen title: 24/28, semibold. - Section title:
18/24, semibold. - Meter name: 17/24, semibold. - Primary numeric value:
24--28, bold. - Supporting value: 14--16, regular/medium. - Metadata and
helper text: 12--13, regular.

Numeric values must remain Latin digits and left-to-right.

### 4.3 Spacing and shape --- proposed

Use a 4-point spacing base: - 4: icon/text micro-gap. - 8: compact
internal gap. - 12: field and row spacing. - 16: standard card
padding. - 20: section spacing. - 24: major screen grouping. - 32: large
separation.

Suggested radii: - Small controls: 10. - Inputs and compact chips: 12. -
Cards: 18. - Large summary panels: 22. - Pills: fully rounded.

Suggested touch target: at least 48 × 48 logical pixels.

### 4.4 RTL and numeric LTR contract

**Global text direction:** Arabic RTL.

**Numeric and unit runs:** always LTR and isolated from surrounding
Arabic text.

Examples: - `12,480 kWh` - `385 kWh` - `248 m³` - `2026/11/09` - `+35%`

Implementation requirements: - Wrap each numeric-plus-unit run in an
explicit LTR directionality boundary. - Do not rely on Unicode
bidirectional heuristics to place units. - Keep the number and its unit
together as one LTR run. - Dates in numeric format are LTR. - Use Latin
unit symbols: `kWh` for electrical energy, `m³` for water/gas volume
when applicable. - Do not label energy consumption as `kW`; kW is power,
while kWh is energy. - If a utility meter uses a different unit, store
and display its configured unit rather than assuming one.

------------------------------------------------------------------------

## 5. Information architecture

### Primary navigation

The three core destinations remain: 1. **العدادات** --- home and meter
list. 2. **إضافة قراءة** --- create a reading. 3. **التحليل** ---
trends, comparisons, pace, and estimates.

The side drawer is a global secondary navigation surface: - Meter and
property management. - Local tariff / pricing configuration. - Alert
threshold and local notification preferences. - Language and theme. -
Local CSV/PDF export.

The notification bell opens a quick-glance alert surface.

### Entity model visible in the UI

Keep these concepts distinct: - **Property/place:** apartment, villa,
shop, pool, or user-defined place. - **Meter:** one physical meter, with
its own type and identity. - **Reading:** a timestamped cumulative meter
value, optionally with a photo. - **Consumption:** the calculated
difference between valid readings for that same meter. - **Alert:** a
rule result associated with a meter and comparison period.

Two electricity meters must appear as two separate meter cards, even
when both belong to the same user.

------------------------------------------------------------------------

## 6. Screen 1 --- Meters (Home)

### Purpose

Give the user a quick, trustworthy overview of every meter and make it
easy to identify which meter needs attention.

### Layout order

1.  **App bar**
    -   App name/brand.
    -   Notification bell with unread/pending indicator.
    -   Side-drawer menu button.
2.  **Consumption overview**
    -   Compact summary by utility type.
    -   Summary must not imply that different meters have aligned
        billing periods if they do not.
    -   If multiple meters of one utility have incompatible periods,
        show a count or separate values rather than a misleading total.
3.  **Meters section header**
    -   Title: `عداداتي`.
    -   Primary action: `إضافة عداد`.
4.  **Scrollable meter list**
    -   One card per physical meter.
    -   No merging of meters of the same type.
5.  **Optional insight panel**
    -   Show only when a meaningful insight exists.
    -   Never let a generic tip displace an urgent reading or alert.
6.  **Bottom navigation**
    -   عدادات / إضافة قراءة / التحليل.

### Meter card anatomy

Recommended content order: - Utility icon and utility label. -
Place/meter name. - Latest cumulative reading + configured unit. -
Latest reading date. - Current-period consumption, when calculable. -
Status chip. - Spike percentage and comparison label, only when a valid
comparison exists. - Trailing navigation affordance.

### Meter card states

  -----------------------------------------------------------------------
  State                               Display
  ----------------------------------- -----------------------------------
  No reading yet                      `لم تُسجل قراءة` + action to add
                                      first reading

  Reading due                         `تحتاج قراءة` with a
                                      neutral/attention state

  Stable                              `مستقر`

  Spike detected                      `زيادة ملحوظة` + `+35%` style
                                      percentage

  Insufficient history                `يلزم تسجيل قراءة أخرى للمقارنة`
                                      where relevant

  Reset/replacement recorded          Show a history-break marker; do not
                                      compare across the reset boundary
  -----------------------------------------------------------------------

### Scrolling behavior

-   The meter list scrolls vertically.
-   All meters remain individually visible in sequence.
-   Bottom navigation remains available.
-   Do not put a fixed-height meter list inside another independently
    scrolling region.
-   The summary area may scroll with the page unless testing proves a
    sticky summary materially improves use.

### Multiple meters example

A user with an apartment electricity meter and a shop electricity meter
sees: - `كهرباء — الشقة` - `كهرباء — المحل`

They are separate cards, with separate readings, dates, histories,
comparisons, and alerts.

------------------------------------------------------------------------

## 7. Screen 2 --- Add Reading

### Purpose

Record a correct reading with minimal friction, with or without a photo.

### Flow

1.  Select the target meter.
2.  Show its previous valid reading and date for context.
3.  Enter the new cumulative reading.
4.  Optionally capture/select a photo.
5.  Set or confirm the reading timestamp.
6.  If the meter was reset or replaced, explicitly mark that event.
7.  Review calculated consumption when calculation is valid.
8.  Save locally and confirm success.

### Form structure

-   Meter selector.
-   Previous reading context.
-   Numeric reading field.
-   Unit label.
-   Date/time field.
-   Photo capture/attachment area.
-   Reset/replacement toggle and explanatory helper text.
-   Calculation preview.
-   Save action.

### Numeric input behavior

-   Numeric keyboard.
-   Accept Latin digits as the canonical stored representation.
-   Validate numeric format and configured meter precision.
-   Never allow a negative consumption result to be silently saved as
    normal usage.
-   Preserve leading zeros only if the meter's reading format requires
    them.
-   Keep the entered value visually LTR.

### Reset/replacement behavior

When enabled: - Ask for explicit confirmation or a clear event type. -
Preserve all historical readings. - Start a new comparison segment. - Do
not calculate a normal consumption difference across the
reset/replacement boundary. - Make the event visible in the meter
history.

### Photo behavior

-   Photo is optional.
-   Clearly show whether a photo is attached.
-   Store photo locally.
-   Bind photo reference, reading value, and timestamp to the same
    reading record.
-   Provide a way to preview the attached photo before saving.

### Save feedback

After a successful local save: - Confirm the reading was saved on this
device. - Show calculated consumption only when valid. - If the reading
creates a spike, show the warning and explain the comparison basis.

------------------------------------------------------------------------

## 8. Screen 3 --- Analytics

### Purpose

Explain how a meter's consumption changes over time without overwhelming
the user.

### Structure

1.  Meter selector.
2.  Current comparison summary.
3.  Monthly consumption line chart.
4.  Month-over-month percentage and absolute variance.
5.  Daily burn rate / pace indicator.
6.  Optional local cost estimate when a tariff is configured.

### Chart rules

-   One selected meter per chart.
-   Show units and period labels clearly.
-   Do not interpolate missing readings as if they were measured.
-   Distinguish measured data from estimated projections.
-   Provide a readable empty state when there is not enough history.
-   Keep chart rendering fully local.

### Cost estimate

-   Hidden or clearly marked as unavailable until a local tariff is
    configured.
-   Label as an estimate, not an official bill.
-   Show the configured tariff basis where practical.

------------------------------------------------------------------------

## 9. Side drawer and settings

### Sections

-   Meter and property management.
-   Meter configuration and local tariff.
-   Alert threshold.
-   Local notification preference.
-   Language.
-   Light/dark theme.
-   CSV/PDF export.

### Interaction principles

-   Destructive actions require confirmation.
-   Deleting a meter must explain the effect on its local history and
    photos.
-   Editing a meter's type or unit must not silently reinterpret old
    readings.
-   Export must remain local and provide a clear destination/share
    action supported by the platform.

------------------------------------------------------------------------

## 10. Alerts and calculation rules

### Spike detection

-   Compare a meter only with its own valid history.
-   Require at least two valid historical readings to establish the
    baseline, as specified in the README.
-   Default threshold may be 30%, but it must be configurable.
-   Clearly show the baseline period and current period.
-   Do not trigger a normal spike comparison across a reset/replacement
    boundary.
-   A spike alert indicates unusual consumption, not the reason for it.

### Data safeguards

-   Reject negative consumption as invalid.
-   Handle meter reset, replacement, and capacity overflow explicitly.
-   Do not calculate consumption where the reading sequence is invalid
    or incomparable.
-   Keep the reading, date/time, and photo association intact.

### Notification behavior

-   Local notifications only.
-   Respect the user's notification preference.
-   The in-app notification surface remains useful if OS notifications
    are disabled.
-   Avoid duplicate alerts for the same meter and comparison period
    unless the underlying state changes.

------------------------------------------------------------------------

## 11. Reusable component inventory

  -----------------------------------------------------------------------
  Component                           Variants / states
  ----------------------------------- -----------------------------------
  `AppHeader`                         Home / secondary screen

  `NotificationButton`                no alert / unread count

  `ConsumptionSummary`                complete / partial / no data

  `UtilityMetric`                     electricity / water / gas

  `MeterCard`                         no reading / due / stable / spike /
                                      insufficient history

  `StatusChip`                        stable / due / warning / invalid

  `NumericUnitValue`                  reading / consumption / percentage
                                      / date

  `MeterSelector`                     selected / unselected / disabled

  `ReadingInput`                      empty / focused / invalid / valid

  `PhotoEvidenceTile`                 empty / attached / preview

  `ResetEventControl`                 off / on / confirmed

  `ConsumptionChart`                  populated / insufficient data

  `InsightPanel`                      hidden / informational / warning

  `BottomNavigation`                  meters / add reading / analytics

  `SideDrawer`                        closed / open
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 12. Accessibility and responsive behavior

-   Maintain readable text sizes and contrast.
-   Do not communicate utility type or status by color alone.
-   Provide labels for icons and chart summaries.
-   Respect Android font scaling where possible.
-   Support narrow Android screens without horizontal scrolling.
-   Keep primary actions reachable and touch targets comfortably sized.
-   Test Arabic text wrapping and numeric LTR runs on real Android
    devices.

------------------------------------------------------------------------

## 13. Open decisions before code implementation

These points are not fully specified by the README and must be confirmed
from product requirements or the existing codebase:

1.  Minimum and maximum supported meter-reading precision per utility.
2.  Whether readings are monthly by default or can be entered at
    arbitrary intervals.
3.  Whether the app supports more than one property group and how
    property selection works.
4.  How tariff tiers are represented and calculated.
5.  Exact definition of the spike comparison period when readings are
    not exactly one month apart.
6.  Whether image capture uses camera only or also gallery import.
7.  Whether local export includes the actual photo files or only
    references.
8.  Database and image-storage technology already selected by the
    project.

Do not invent these behaviors during UI implementation.

------------------------------------------------------------------------

## 14. Implementation acceptance checklist

### Home

-   [ ] Every physical meter has its own card.
-   [ ] Multiple meters of the same utility remain separate.
-   [ ] The list scrolls vertically without nested-scroll conflicts.
-   [ ] Latest reading is visually distinct from period consumption.
-   [ ] Status is communicated by text/icon as well as color.
-   [ ] Summary does not aggregate incompatible periods.

### Add Reading

-   [ ] Meter selection is explicit.
-   [ ] Numeric input and unit display are LTR.
-   [ ] Photo is optional and locally attached to the reading.
-   [ ] Timestamp is stored with the reading.
-   [ ] Reset/replacement creates a comparison boundary.
-   [ ] Invalid negative consumption is not accepted as normal use.

### Analytics

-   [ ] One meter's history is shown at a time.
-   [ ] Insufficient history has a clear empty state.
-   [ ] Missing data is not presented as measured data.
-   [ ] Cost is clearly marked as an estimate.

### Global

-   [ ] Core flows work offline.
-   [ ] Local notifications respect preferences.
-   [ ] Arabic RTL and numeric LTR are tested on Android.
-   [ ] Theme switching preserves contrast and hierarchy.
-   [ ] No undocumented behavior is added.

------------------------------------------------------------------------

## 15. Next implementation gate

This document establishes the design and interaction contract. It does
not claim that Flutter code has been implemented or tested.

To produce production Flutter screens, the current source repository or
project archive is required. The implementation must first inspect the
existing architecture, dependencies, database, and navigation before
modifying code.
